//
//  UserDefaultsManager.h
//  WeatherFrog
//
//  Created by Libor Kučera on 31.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const DefaultsFetchForecastInBackground = @"FETCH_FORECAST_IN_BACKGROUND";
static NSString* const DefaultsShareLocationAndForecast = @"SHARE_LOCATION_AND_FORECAST";
static NSString* const DefaultsNotifications = @"NOTIFICATIONS";
static NSString* const DefaultsDisplayMode = @"DISPLAY_MODE";
static NSString* const DefaultsSoundEffects = @"SOUND_EFFECTS";
static NSString* const DefaultsOnScreenHelp = @"ON_SCREEN_HELP";
static NSString* const DefaultsLocationGeocoderAccuracy = @"LOCATION_GEOCODER_ACCURACY";
static NSString* const DefaultsLocationGeocoderTimeout = @"LOCATION_GEOCODER_TIMEOUT";
static NSString* const DefaultsForecastAccuracy = @"FORECAST_ACCURACY";
static NSString* const DefaultsForecastValidity = @"FORECAST_VALIDITY";
static NSString* const DefaultsForecastUnitTemperature = @"FORECAST_UNIT_TEMPERATURE";
static NSString* const DefaultsForecastUnitWindspeed = @"FORECAST_UNIT_WINDSPEED";
static NSString* const DefaultsForecastUnitPrecipitation = @"FORECAST_UNIT_PRECIPITATION";
static NSString* const DefaultsForecastUnitPressure = @"FORECAST_UNIT_PRESSURE";
static NSString* const DefaultsForecastUnitAltitude = @"FORECAST_UNIT_ALTITUDE";
static NSString* const DefaultsLastNotificationSymbol = @"LAST_NOTIFICATION_SYMBOL";
static NSString* const DefaultsLimitedMode = @"LIMITED_MODE";

@interface UserDefaultsManager : NSObject

@property (nonatomic) BOOL fetchForecastInBackground;
@property (nonatomic) BOOL shareLocationAndForecast;
@property (nonatomic, strong) NSNumber* notifications;
@property (nonatomic, strong) NSString* displayMode;
@property (nonatomic) BOOL soundEffects;
@property (nonatomic) BOOL onScreenHelp;
@property (nonatomic, strong) NSNumber* locationGeocoderAccuracy;
@property (nonatomic, strong) NSNumber* locationGeocoderTimeout;
@property (nonatomic, strong) NSNumber* forecastAccuracy;
@property (nonatomic, strong) NSNumber* forecastValidity;
@property (nonatomic, strong) NSString* forecastUnitTemperature;
@property (nonatomic, strong) NSString* forecastUnitWindspeed;
@property (nonatomic, strong) NSString* forecastUnitPrecipitation;
@property (nonatomic, strong) NSString* forecastUnitPressure;
@property (nonatomic, strong) NSString* forecastUnitAltitude;
@property (nonatomic, strong) NSNumber* lastNotificationSymbol;
@property (nonatomic) BOOL limitedMode;

+ (UserDefaultsManager *)sharedDefaults;

- (NSArray*)elementsSections;
- (NSString*)elementTitleForKey:(NSString*)key;
- (id)elementValueForKey:(NSString*)key;
- (NSString*)titleOfMultiValue:(id)value forKey:(NSString*)key;
- (NSString*)titleOfSliderValue:(id)value forKey:(NSString*)key;
- (NSArray*)titlesForKey:(NSString*)key;
- (NSArray*)valuesForKey:(NSString*)key;
- (NSNumber*)minValueForKey:(NSString *)key;
- (NSNumber*)maxValueForKey:(NSString *)key;

@end
