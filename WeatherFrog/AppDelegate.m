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
#import "Location+Store.h"

@implementation AppDelegate {
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
    BOOL hostActive;
    CLLocationManager* locationManager;
    CLGeocoder* geocoder;
    Weather* lastNotification;
    NSDictionary* notificationsConfig;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    LumberjackFormatter *formatter = [[LumberjackFormatter alloc] init];
	[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    internetActive = [internetReachable isReachable];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostname:kAPIHost];
    hostActive = [hostReachable isReachable];
    [hostReachable startNotifier];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    [MagicalRecord setupCoreDataStack];
    [UserDefaultsManager sharedDefaults];
    [self customizeUIKit];
    
    // Facebook
    [FBProfilePictureView class];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
        [self openSession];
    }
    
    // CLLocation
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.distanceFilter = 500;
        locationManager.delegate = self;
    }
    
    // CLGeocoder
    if (geocoder == nil) {
        geocoder = [[CLGeocoder alloc] init];
    }
    
    if (launchOptions != nil) {
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
            DDLogVerbose(@"Launched from Local notification %@", [[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] description]);
            //DO NOTHING, App will start to required controller and state
        }
    }
    
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
    
    if ([CLLocationManager locationServicesEnabled] == YES) {
        [locationManager startMonitoringSignificantLocationChanges];
    } else {
        [locationManager stopUpdatingLocation];
        [locationManager stopMonitoringSignificantLocationChanges];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([CLLocationManager locationServicesEnabled] == YES) {
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [locationManager startUpdatingLocation];
        } else {
            [locationManager startMonitoringSignificantLocationChanges];
        }
        
    } else {
        [locationManager stopUpdatingLocation];
        [locationManager stopMonitoringSignificantLocationChanges];
    }
    
    [FBAppEvents activateApp];
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
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
    
    if ([[UserDefaultsManager sharedDefaults] fetchForecastInBackground] == YES && _currentLocation != nil) {
        
        ForecastManager* forecastManager = [[ForecastManager alloc] init];
        forecastManager.delegate = nil;
        [forecastManager forecastWithPlacemark:_currentPlacemark timezone:[NSTimeZone localTimeZone] successWithNewData:^(Forecast *forecast) {
            _currentForecast = forecast;
            [self forecastNotifcation];
            completionHandler(UIBackgroundFetchResultNewData);
        } withLoadedData:^(Forecast *forecast) {
            [self forecastNotifcation];
            completionHandler(UIBackgroundFetchResultNoData);
        } failure:^{
            completionHandler(UIBackgroundFetchResultNoData);
        }];
        
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

#pragma mark - Customize UIKit

- (void)customizeUIKit
{
    
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
        
    } else {
        DDLogVerbose(@"Host is not Reachable");
        hostActive = NO;
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
    if (status != kCLAuthorizationStatusAuthorized) {
        [locationManager stopUpdatingLocation];
        [locationManager stopMonitoringSignificantLocationChanges];
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
        if (_currentLocation != nil && [lastLocation distanceFromLocation:_currentLocation] < [forecastAccuracy floatValue]) {
            return;
        }
        
        _currentLocation = lastLocation;
        [[NSNotificationCenter defaultCenter] postNotificationName:LocationManagerUpdateNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:_currentLocation, @"currentLocation", nil]];
        DDLogVerbose(@"location: %@", [_currentLocation description]);
        
        if (internetActive) {
            [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if ([placemarks count] > 0) {
                    _currentPlacemark = placemarks[0];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:ReverseGeocoderUpdateNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:_currentPlacemark, @"currentPlacemark", nil]];
                    DDLogVerbose(@"placemark: %@", [_currentPlacemark description]);
                    
                    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
                    if (_currentLocation != nil && (applicationState != UIApplicationStateBackground || [[UserDefaultsManager sharedDefaults] fetchForecastInBackground])) {
                        
                        ForecastManager* forecastManager = [[ForecastManager alloc] init];
                        forecastManager.delegate = self;
                        [forecastManager forecastWithPlacemark:_currentPlacemark timezone:[NSTimeZone localTimeZone] forceUpdate:YES];
                    }
                }
            }];
        }
    }
}

#pragma mark - ForecastManagerDelegate

- (void)forecastManager:(id)manager didFinishProcessingForecast:(Forecast *)forecast
{
    DDLogInfo(@"didFinishProcessingForecast");
    _currentForecast = forecast;
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastUpdateNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:_currentForecast, @"currentForecast", nil]];
    [self forecastNotifcation];
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

- (void)forecastNotifcation
{
    DDLogInfo(@"forecastNotifcation");
    DDLogVerbose(@"forecast: %@", [_currentForecast description]);
    
    NSDate* now = [NSDate date];
    
    __block Weather* currentNotification;
    
    [_currentForecast.weather enumerateObjectsUsingBlock:^(Weather* weather, NSUInteger idx, BOOL *stop) {
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
                
                NSString* alertBody = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Notification", nil), [sharedDefaults titleOfSliderValue:notifications forKey:DefaultsNotifications]];
                notifyAlarm.alertBody = alertBody;
                [app scheduleLocalNotification:notifyAlarm];
            }
            
        }
        
    }
    
    lastNotification = currentNotification;
}

@end
