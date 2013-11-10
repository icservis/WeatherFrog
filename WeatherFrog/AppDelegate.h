//
//  AppDelegate.h
//  WeatherFrog
//
//  Created by Libor Kučera on 16.06.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForecastManager.h"

@class Forecast;

static NSString* const ReachabilityNotification = @"REACHABILITY_NOTIFICATION";
static NSString* const LocationManagerUpdateNotification = @"LOCATION_MANAGER_UPDATE_NOTIFICATION";
static NSString* const LocationManagerUpdateUnderTresholdNotification = @"LOCATION_MANAGER_UPDATE_UNDER_TRESHOLD_NOTIFICATION";
static NSString* const ReverseGeocoderUpdateNotification = @"REVERSE_GEOCODER_UPDATE_NOTIFICATION";
static NSString* const ReverseGeocoderFailNotification = @"REVERSE_GEOCODER_FAIL_NOTIFICATION";
static NSString* const ForecastErrorNotification = @"FORECAST_ERROR_NOTIFICATION";
static NSString* const ForecastFetchNotification = @"FORECAST_FETCH_NOTIFICATION";
static NSString* const ForecastProgressNotification = @"FORECAST_PROGRESS_NOTIFICATION";
static NSString* const ForecastUpdateNotification = @"FORECAST_UPDATE_NOTIFICATION";
static NSString* const ApplicationReceivedLocalNotification = @"APPLICATION_RECEIVED_LOCAL_NOTIFICATION";

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, ForecastManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) CLPlacemark* currentPlacemark;
@property (strong, nonatomic) Forecast* currentForecast;
@property (strong, nonatomic) DDFileLogger* fileLogger;

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

/**
 Reachability status variables.
 */
- (BOOL)isInternetActive;
- (BOOL)isHostActive;

/**
 Geocoder
 */
- (BOOL)restartGeocoder;

/**
 Coredata
 */
- (void)savePersistence;

/**
 User locale.
 */
- (NSString*)localeCountryCode;
- (NSString*)localeLanguageCode;

/**
 Application version.
 */
- (NSString*)appVersion;
- (NSString*)appVersionBuild;

@end
