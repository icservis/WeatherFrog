//
//  AppDelegate.m
//  WeatherFrog
//
//  Created by Libor Kučera on 16.06.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Forecast.h"
#import "Weather.h"
#import "Location.h"
#import "LocationManager.h"

@implementation AppDelegate {
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
    BOOL hostActive;
    CLLocationManager* clLocationManager;
    CLGeocoder* clGeocoder;
    Weather* lastNotification;
    NSDictionary* notificationsConfig;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Logging.
    LumberjackFormatter *formatter = [[LumberjackFormatter alloc] init];
	[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Activity Manager
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    internetActive = [internetReachable isReachable];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostname:kAPIHost];
    hostActive = [hostReachable isReachable];
    [hostReachable startNotifier];
    
    // Core data
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    // User defaults
    [UserDefaultsManager sharedDefaults];
    [self customizeUIKit];
    
    // Facebook
    [FBProfilePictureView class];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
        [self openSession];
    }
    
    // CLLocation
    if (clLocationManager == nil) {
        clLocationManager = [[CLLocationManager alloc] init];
        clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        clLocationManager.distanceFilter = 500;
        clLocationManager.delegate = self;
    }
    
    // CLGeocoder
    if (clGeocoder == nil) {
        clGeocoder = [[CLGeocoder alloc] init];
    }
    
    if (launchOptions != nil) {
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
            DDLogVerbose(@"Launched from Local notification %@", [[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] description]);
            //DO NOTHING, App will start to required controller and state
        }
    }
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    // Background Fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:kBackgoundFetchInterval];
    
    // Notifications config
    NSArray* notificationsConfigLow = @[@20, @21, @22, @23];
    NSArray* notificationsConfigMiddle = @[@10, @11, @12, @13, @14, @18, @19, @20, @21, @22, @23];
    NSArray* notificationsConfigHigh = @[@5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @18, @19, @20, @21, @22, @23];
    
    notificationsConfig = @{
                            @1 : notificationsConfigLow,
                            @2 : notificationsConfigMiddle,
                            @3 : notificationsConfigHigh
                        };

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    if ([CLLocationManager locationServicesEnabled] == YES && [[UserDefaultsManager sharedDefaults] fetchForecastInBackground] == YES) {
        [clLocationManager startMonitoringSignificantLocationChanges];
    } else {
        [clLocationManager stopUpdatingLocation];
        [clLocationManager stopMonitoringSignificantLocationChanges];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self savePersistence];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([CLLocationManager locationServicesEnabled] == YES) {
        
        [clLocationManager startUpdatingLocation];
        
    } else {
        [clLocationManager stopUpdatingLocation];
        [clLocationManager stopMonitoringSignificantLocationChanges];
    }
    
    [FBAppEvents activateApp];
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
    [self savePersistence];
}

#pragma mark - State preservation and restoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    DDLogVerbose(@"shouldSaveApplicationState");
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    DDLogVerbose(@"shouldRestoreApplicationState");
    return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    DDLogVerbose(@"viewControllerWithRestorationIdentifierPath %@", identifierComponents);
    UIViewController* viewController = nil;
    NSString* identifier = [identifierComponents lastObject];
    UIStoryboard* storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    
    if (storyboard != nil) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        if (viewController != nil) {
            DDLogVerbose(@"viewController: %@", [viewController description]);
            viewController.restorationIdentifier = identifier;
        }
    }
    
    return viewController;
}

#pragma mark - UIApplicationDelegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogVerbose(@"didReceiveLocalNotification: %@", [notification description]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationReceivedLocalNotification object:self userInfo:notification.userInfo];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DDLogInfo(@"performFetchWithCompletionHandler");
    
    if ([[UserDefaultsManager sharedDefaults] fetchForecastInBackground] == YES && internetActive) {
        
        CLLocation* currentLocation = clLocationManager.location;
        if (currentLocation == nil) {
            DDLogError(@"current location not determined");
            completionHandler(UIBackgroundFetchResultNoData);
        }
        DDLogVerbose(@"Current location restored");
        _currentLocation = currentLocation;
    
        [clGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0) {
                _currentPlacemark = placemarks[0];
                DDLogVerbose(@"Restoring current placemark completed");
                
                ForecastManager* forecastManager = [[ForecastManager alloc] init];
                forecastManager.delegate = nil;
                [forecastManager forecastWithPlacemark:_currentPlacemark timezone:[NSTimeZone localTimeZone] successWithNewData:^(Forecast *forecast) {
                    _currentForecast = forecast;
                    DDLogVerbose(@"New data");
                    [self forecastNotifcation:@"fetch with new data"];
                    completionHandler(UIBackgroundFetchResultNewData);
                } withLoadedData:^(Forecast *forecast) {
                    [self forecastNotifcation:@"fetch with loaded data"];
                    DDLogVerbose(@"Loaded data");
                    completionHandler(UIBackgroundFetchResultNoData);
                } failure:^{
                    DDLogVerbose(@"Error");
                    completionHandler(UIBackgroundFetchResultFailed);
                }];
                
            } else {
                DDLogVerbose(@"Restoring current placemark failed");
                completionHandler(UIBackgroundFetchResultNoData);
            }
        }];
        
        
    } else {
        DDLogInfo(@"No background operations");
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

#pragma mark - Customize UIKit

- (void)customizeUIKit
{
    
}

#pragma mark - Core Data

- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSString* modelPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
        NSURL* modelURL = [NSURL fileURLWithPath:modelPath];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSString*)documentsDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        NSURL* storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError* error;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            DDLogError(@"Error adding persistent store %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator* coordinator = self.persistentStoreCoordinator;
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (void)savePersistence
{
    LocationManager* locationManager = [[LocationManager alloc] init];
    [locationManager deleteObsoleteLocations];
    
    NSError* error;
    if ([self.managedObjectContext save:&error]) {
        DDLogInfo(@"CoreData saved");
    } else {
        DDLogError(@"CoreData error: %@", [error localizedDescription]);
    }
}

#pragma mark - Internet reachability

-(void)checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case NotReachable:
        {
            DDLogVerbose(@"The internet is down.");
            internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            DDLogVerbose(@"The internet is working via WIFI.");
            internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            DDLogVerbose(@"The internet is working via WWAN.");
            internetActive = YES;
            break;
        }
    }
    
    if (hostStatus == ReachableViaWiFi || hostStatus == ReachableViaWWAN) {
        
        DDLogVerbose(@"Host is Active");
        hostActive = YES;
        [self setBackgroundFetchOperation];
        
    } else {
        DDLogVerbose(@"Host is not Reachable");
        hostActive = NO;
        [self setBackgroundFetchOperation];
    }
    
    NSDictionary* dict = @{@"hostActive":[NSNumber numberWithBool:hostActive], @"internetActive":[NSNumber numberWithBool:internetActive]};
    [[NSNotificationCenter defaultCenter] postNotificationName:ReachabilityNotification object:self userInfo:dict];
}

- (BOOL)isInternetActive
{
    return internetActive;
}

- (BOOL)isHostActive
{
    return hostActive;
}

#pragma mark - notifications

- (void)defaultsChanged:(NSNotification*)notification
{
    DDLogInfo(@"defaultsChanged");
    [self setBackgroundFetchOperation];
}

#pragma mark - user locale

- (NSString*)localeCountryCode
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey: NSLocaleCountryCode];
}

- (NSString*)localeLanguageCode
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey: NSLocaleLanguageCode];
}

#pragma mark - background operations

- (void)setBackgroundFetchOperation
{
    BOOL allowed = YES;
    
    if (internetActive == NO) allowed = NO;
    
    UserDefaultsManager* sharedDefaults = [UserDefaultsManager sharedDefaults];
    BOOL fetchForecastInBackground = [sharedDefaults fetchForecastInBackground];
    if (fetchForecastInBackground == NO) allowed = NO;
    
    if (allowed) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:kBackgoundFetchInterval];
    } else {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    }
}

#pragma mark - Facebook

// FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of FBAppCall the provided
// session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    self.session = session;
    DDLogVerbose(@"session: %@", [self.session description]);
    
    switch (state) {
        case FBSessionStateOpen: {
            
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *fbUser,
               NSError *error) {
                 if (!error) {
                     DDLogVerbose(@"fbUser: %@", [fbUser description]);
                     _fbUser = fbUser;
                     [[NSNotificationCenter defaultCenter] postNotificationName:FbSessionOpenedNotification object:self userInfo:fbUser];
                 } else {
                     _fbUser = fbUser;
                     DDLogError(@"fb error: %@", [error localizedDescription]);
                 }
             }];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [FBSession.activeSession closeAndClearTokenInformation];
            _fbUser = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:FbSessionClosedNotification object:self userInfo:nil];
        }
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Caution", nil)
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Facebook session

- (void)openSession
{
    DDLogInfo(@"openSession");
    [FBSession openActiveSessionWithReadPermissions:[[NSArray alloc] initWithObjects:@"email", nil]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)closeSession
{
    DDLogInfo(@"closeSession");
    [FBSession.activeSession closeAndClearTokenInformation];
    _session = nil;
    _fbUser = nil;
}

#pragma mark - Application version

- (NSString*)appVersion
{
    NSString *myVersion, *versText;
    
    myVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (myVersion) {
        versText = [NSString stringWithFormat:@"%@", myVersion];
    }
    return versText;
}

- (NSString*)appVersionBuild
{
    NSString *myVersion, *buildNum, *versText;
    
    myVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    if (myVersion) {
        if (buildNum)
            versText = [NSString stringWithFormat:@"%@ (%@)", myVersion, buildNum];
        else
            versText = [NSString stringWithFormat:@"%@", myVersion];
    }
    else if (buildNum)
        versText = [NSString stringWithFormat:@"%@", buildNum];
    return versText;
}

#pragma mark - CLLocationDelegete

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        DDLogInfo(@"Stop locator");
        
        [clLocationManager stopUpdatingLocation];
        [clLocationManager stopMonitoringSignificantLocationChanges];
        
    } else if (status == kCLAuthorizationStatusAuthorized) {
        DDLogInfo(@"Start locator");
        
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
            [clLocationManager startUpdatingLocation];
        } else if ([[UserDefaultsManager sharedDefaults] fetchForecastInBackground] == YES) {
            [clLocationManager startMonitoringSignificantLocationChanges];
        } else {
            [clLocationManager stopUpdatingLocation];
            [clLocationManager stopMonitoringSignificantLocationChanges];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* lastLocation = [locations lastObject];
    NSDate* eventDate = lastLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    CLLocationAccuracy accuracy = lastLocation.horizontalAccuracy;
    
    if (abs(howRecent) < 15.0 && accuracy < kCLLocationAccuracyHundredMeters) {
        
        NSNumber* forecastAccuracy = [[UserDefaultsManager sharedDefaults] forecastAccuracy];
        if (self.currentLocation != nil && [lastLocation distanceFromLocation:self.currentLocation] < [forecastAccuracy floatValue]) {
            DDLogVerbose(@"distance under limit");
            return;
        }
        
        self.currentLocation = lastLocation;
    }
}

- (BOOL)restartGeocoder
{
    DDLogInfo(@"restart");
    
    CLLocation* currentLocation = clLocationManager.location;
    if (currentLocation != nil) {
        self.currentLocation = currentLocation;
        DDLogInfo(@"location restored");
        return YES;
    } else {
        DDLogInfo(@"restarting geocoder");
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
            [clLocationManager startUpdatingLocation];
        } else {
            [clLocationManager startMonitoringSignificantLocationChanges];
        }
        return NO;
    }
    
}

#pragma mark - Setters

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    DDLogInfo(@"setCurrentLocation");
    _currentLocation = currentLocation;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationManagerUpdateNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:currentLocation, @"currentLocation", nil]];
    DDLogVerbose(@"location: %@", [currentLocation description]);
    
    if (internetActive) {
        [clGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0) {
                self.currentPlacemark = placemarks[0];
            } else {
                DDLogError(@"geocoder error: %@", [error description]);
            }
        }];
    } else {
        DDLogError(@"internet not active");
    }
}

- (void)setCurrentPlacemark:(CLPlacemark *)currentPlacemark
{
    DDLogInfo(@"setCurrentPlacemark");
    _currentPlacemark = currentPlacemark;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReverseGeocoderUpdateNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:currentPlacemark, @"currentPlacemark", nil]];
    DDLogVerbose(@"placemark: %@", [currentPlacemark description]);
    
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    if (self.currentLocation != nil && (applicationState != UIApplicationStateBackground || [[UserDefaultsManager sharedDefaults] fetchForecastInBackground])) {
        
        ForecastManager* forecastManager = [[ForecastManager alloc] init];
        forecastManager.delegate = self;
        [forecastManager forecastWithPlacemark:currentPlacemark timezone:[NSTimeZone localTimeZone] forceUpdate:YES];
    }
}

#pragma mark - ForecastManagerDelegate

- (void)forecastManager:(id)manager didStartFetchingForecast:(ForecastStatus)status
{
    DDLogInfo(@"didStartFetchingForecast");
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastFetchNotification object:self userInfo:nil];
}

- (void)forecastManager:(id)manager didFinishProcessingForecast:(Forecast *)forecast
{
    DDLogInfo(@"didFinishProcessingForecast");
    self.currentForecast = forecast;
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastUpdateNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:self.currentForecast, @"currentForecast", nil]];
    [self forecastNotifcation:@"geolocator"];
}

- (void)forecastManager:(id)manager didFailProcessingForecast:(Forecast *)forecast error:(NSError *)error
{
    DDLogError(@"didFailProcessingForecast");
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:error, @"forecastError", nil]];
    DDLogError(@"Error: %@", [error description]);
}

- (void)forecastManager:(id)manager updatingProgressProcessingForecast:(float)progress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastProgressNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:progress], @"forecastProgress", nil]];
}

#pragma mark - Forecast notification

- (void)forecastNotifcation:(NSString*)message
{
    DDLogInfo(@"forecastNotifcation");
    
    NSDate* now = [NSDate date];
    
    __block Weather* currentNotification;
    
    [self.currentForecast.weather enumerateObjectsUsingBlock:^(Weather* weather, NSUInteger idx, BOOL *stop) {
        if ([weather.timestamp compare:now] == NSOrderedDescending) {
            
            currentNotification = weather;
            *stop = YES;
        }
    }];
    
    if (lastNotification != nil && [lastNotification.created isEqualToDate:currentNotification.created] && [lastNotification.timestamp isEqualToDate:currentNotification.timestamp]) {
        
        DDLogInfo(@"Duplicated weather");
        return;
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        UserDefaultsManager* sharedDefaults = [UserDefaultsManager sharedDefaults];
        NSNumber* notifications = [sharedDefaults notifications];
        NSUInteger notificationLevel = [notifications integerValue];
            
        BOOL sheduleNotification = NO;
        
        if (notificationLevel == 4) {
            
            sheduleNotification = YES;
            
        } else if (notificationLevel > 0) {
            
            NSNumber* symbol;
            
            if (currentNotification.symbol1h != nil) {
                symbol = currentNotification.symbol1h;
            } else if (currentNotification.symbol2h != nil) {
                symbol = currentNotification.symbol2h;
            } else if (currentNotification.symbol3h != nil) {
                symbol = currentNotification.symbol3h;
            } else {
                symbol = currentNotification.symbol6h;
            }
            
            NSArray* notificationLevelConfig = [notificationsConfig objectForKey:notifications];
            
            if ([notificationLevelConfig indexOfObject:symbol] != NSNotFound) {
                if (![sharedDefaults.lastNotificationSymbol isEqualToNumber:symbol]) {
                    sheduleNotification = YES;
                    sharedDefaults.lastNotificationSymbol = symbol;
                }
            } else {
                sheduleNotification = NO;
                sharedDefaults.lastNotificationSymbol = @0;
            }
            
            DDLogVerbose(@"symbol: %@", symbol);
            DDLogVerbose(@"lastNotificationSymbol: %@", sharedDefaults.lastNotificationSymbol);
            
        }
        
        if (sheduleNotification) {
            
            DDLogInfo(@"sheduleNotification");
            
            NSDate *alertTime = [[NSDate date] dateByAddingTimeInterval:0.5];
            UIApplication* app = [UIApplication sharedApplication];
            UILocalNotification* notifyAlarm = [[UILocalNotification alloc] init];
            if (notifyAlarm) {
                notifyAlarm.fireDate = alertTime;
                notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
                notifyAlarm.repeatInterval = 0;
                
                NSString* alertBody = [NSString stringWithFormat:@"%@ %@ - %@", NSLocalizedString(@"Notification", nil), [sharedDefaults titleOfSliderValue:notifications forKey:DefaultsNotifications], message];
                notifyAlarm.alertBody = alertBody;
                [app scheduleLocalNotification:notifyAlarm];
            }
            
        }
        
    }
    
    lastNotification = currentNotification;
}

@end
