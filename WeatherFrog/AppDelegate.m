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
#import "Location.h"
#import "Location+Store.h"

@implementation AppDelegate {
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
    BOOL hostActive;
    CLLocationManager* locationManager;
    CLGeocoder* geocoder;
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
            DDLogInfo(@"The internet is down.");
            internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            DDLogInfo(@"The internet is working via WIFI.");
            internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            DDLogInfo(@"The internet is working via WWAN.");
            internetActive = YES;
            break;
        }
    }
    
    if (hostStatus == ReachableViaWiFi || hostStatus == ReachableViaWWAN) {
        
        DDLogInfo(@"Host is Active");
        hostActive = YES;
        
    } else {
        DDLogInfo(@"Host is not Reachable");
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

#pragma mark - iser locale

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
    DDLogInfo(@"status: %i", status);
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
        
        if (_currentLocation != nil && [lastLocation distanceFromLocation:_currentLocation] < kForecastAccuracy) {
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
                    
                    ForecastManager* forecastManager = [[ForecastManager alloc] init];
                    forecastManager.delegate = self;
                    [forecastManager forecastWithPlacemark:_currentPlacemark timezone:[NSTimeZone localTimeZone] forceUpdate:YES];
                }
            }];
        }
    }
}

#pragma mark - ForecastManagerDelegate

- (void)forecastManager:(id)manager didFinishProcessingForecast:(Forecast *)forecast
{
    _currentForecast = forecast;
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastUpdateNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:_currentForecast, @"currentForecast", nil]];
    DDLogVerbose(@"forecast: %@", [_currentForecast description]);
}

- (void)forecastManager:(id)manager didFailProcessingForecast:(Forecast *)forecast error:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastErrorNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:error, @"forecastError", nil]];
    DDLogError(@"Error: %@", [error description]);
}

- (void)forecastManager:(id)manager updatingProgressProcessingForecast:(float)progress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ForecastProgressNotification object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:progress], @"forecastProgress", nil]];
}

@end
