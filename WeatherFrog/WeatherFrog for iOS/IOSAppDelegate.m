//
//  AppDelegate.m
//  WeatherFrog for iOS
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSAppDelegate.h"
#import "PositionManager.h"
#import "ForecastManager.h"

@interface IOSAppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong, readwrite) CLLocation* currentLocation;
@property (nonatomic, strong, readwrite) CLPlacemark* currentPlacemark;
@property (nonatomic, strong, readwrite) Position* currentPosition;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLGeocoder* geocoder;

@end

@implementation IOSAppDelegate

@synthesize currentLocation = _currentLocation;
@synthesize currentPlacemark = _currentPlacemark;
@synthesize currentPosition = _currentPosition;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Logging.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogDebug(@"applicationDirectory: %@", [[DataService sharedInstance] applicationDocumentsDirectory]);
    
    //[self startMonitoringCurrentLocation];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[DataService sharedInstance] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[DataService sharedInstance] saveContext];
    [self stopMonitoringCurrentLocation];
}

#pragma mark - Current Location

- (CLLocationManager*)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_locationManager performSelector:@selector(requestAlwaysAuthorization)];
            }
        }
        
#pragma clang diagnostic pop
    }
    return _locationManager;
}

- (CLGeocoder*)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)startMonitoringCurrentLocation
{
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoringCurrentLocation
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] > 0) {
        CLLocation* location = [locations firstObject];
        //DDLogVerbose(@"location: %@", location);
        self.currentLocation = location;
        
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil) {
                CLPlacemark* placemark = [placemarks firstObject];
                //DDLogVerbose(@"placemark: %@", placemark);
                self.currentPlacemark = placemark;
                NSString* timezoneId = [[NSTimeZone localTimeZone] name];
                self.currentPosition = [[PositionManager sharedManager] positionForPlacemark:placemark timezoneId:timezoneId];                
                [[ForecastManager sharedManager] updateForecastForPosition:self.currentPosition withCompletionBlock:^(BOOL updated, NSError *error) {
                    if (updated) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kForecastManagerDidUpdateCurrentLocationData object:nil];
                        [self procesCurrentForecastData];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Processing new forecast

- (void)procesCurrentForecastData
{
    //DDLogVerbose(@"%@", self.currentPosition);
}

@end
