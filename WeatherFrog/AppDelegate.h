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
static NSString* const ReverseGeocoderUpdateNotification = @"REVERSE_GEOCODER_UPDATE_NOTIFICATION";
static NSString* const ForecastErrorNotification = @"FORECAST_Error_NOTIFICATION";
static NSString* const ForecastProgressNotification = @"FORECAST_PROGRESS_NOTIFICATION";
static NSString* const ForecastUpdateNotification = @"FORECAST_UPDATE_NOTIFICATION";
static NSString* const FbSessionOpenedNotification = @"FBSESSION_OPENED_NOTIFICATION";
static NSString* const FbSessionClosedNotification = @"FBSESSION_CLOSED_NOTIFICATION";
static NSString* const ApplicationReceivedLocalNotification = @"APPLICATION_RECEIVED_LOCAL_NOTIFICATION";

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, ForecastManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession* session;
@property (strong, nonatomic) NSDictionary<FBGraphUser>* fbUser;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) CLPlacemark* currentPlacemark;
@property (strong, nonatomic) Forecast* currentForecast;

/**
 Reachability status variables.
 */
- (BOOL)isInternetActive;
- (BOOL)isHostActive;

/**
 Facebook status variables.
 */
- (void)openSession;
- (void)closeSession;

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
