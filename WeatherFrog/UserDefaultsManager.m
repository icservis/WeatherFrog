//
//  UserDefaultsManager.m
//  WeatherFrog
//
//  Created by Libor Kučera on 31.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "UserDefaultsManager.h"

@interface UserDefaultsManager ()

@property (nonatomic, strong) NSUserDefaults* standardDefaults;

@end

@implementation UserDefaultsManager

+ (UserDefaultsManager *)sharedDefaults {
    
    static UserDefaultsManager* _sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDefaults = [[self alloc] init];
    });
    
    return _sharedDefaults;
}

#pragma mark - Standard Defaults

@synthesize standardDefaults = _standardDefaults;

- (NSUserDefaults *)standardDefaults
{
    if (_standardDefaults == nil) {
        _standardDefaults = [NSUserDefaults standardUserDefaults];
        
        NSArray* preferenceArray = [self preferenceArray];
        NSMutableDictionary* registerableDictionary = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < [preferenceArray count]; i++)  {
            NSString  *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
            
            if (key)  {
                id  value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
                [registerableDictionary setObject:value forKey:key];
            }
        }
        
        [_standardDefaults registerDefaults:registerableDictionary];
        [_standardDefaults synchronize];
    }
    return _standardDefaults;
}

#pragma mark - Fetch Forecast in Background

@synthesize fetchForecastInBackground = _fetchForecastInBackground;

- (void)setFetchForecastInBackground:(BOOL)fetchForecastInBackground
{
    _fetchForecastInBackground = fetchForecastInBackground;
    [self.standardDefaults setBool:fetchForecastInBackground forKey:DefaultsFetchForecastInBackground];
    [self.standardDefaults synchronize];
}

- (BOOL)fetchForecastInBackground
{
    _fetchForecastInBackground = [self.standardDefaults boolForKey:DefaultsFetchForecastInBackground];
    return _fetchForecastInBackground;
}

#pragma mark - Share Location and Forecast

@synthesize shareLocationAndForecast = _shareLocationAndForecast;

- (void)setShareLocationAndForecast:(BOOL)shareLocationAndForecast
{
    _shareLocationAndForecast = shareLocationAndForecast;
    [self.standardDefaults setBool:shareLocationAndForecast forKey:DefaultsShareLocationAndForecast];
    [self.standardDefaults synchronize];
}

- (BOOL)shareLocationAndForecast
{
    _shareLocationAndForecast = [self.standardDefaults boolForKey:DefaultsShareLocationAndForecast];
    return _shareLocationAndForecast;
}

#pragma mark - Display Mode

@synthesize displayMode = _displayMode;

- (void)setDisplayMode:(NSString *)displayMode
{
    _displayMode = displayMode;
    [self.standardDefaults setValue:displayMode forKey:DefaultsDisplayMode];
    [self.standardDefaults synchronize];
}

- (NSString*)displayMode
{
    _displayMode = [self.standardDefaults valueForKey:DefaultsDisplayMode];
    return _displayMode;
}

#pragma mark - Sound Effects

@synthesize soundEffects = _soundEffects;

- (void)setSoundEffects:(BOOL)soundEffects
{
    _soundEffects = soundEffects;
    [self.standardDefaults setBool:soundEffects forKey:DefaultsSoundEffects];
    [self.standardDefaults synchronize];
}

- (BOOL)soundEffects
{
    _soundEffects = [self.standardDefaults boolForKey:DefaultsSoundEffects];
    return _soundEffects;
}

#pragma mark - On Screen Help

@synthesize onScreenHelp = _onScreenHelp;

- (void)setOnScreenHelp:(BOOL)onScreenHelp
{
    _onScreenHelp = onScreenHelp;
    [self.standardDefaults setBool:onScreenHelp forKey:DefaultsOnScreenHelp];
    [self.standardDefaults synchronize];
}

- (BOOL)onScreenHelp
{
    _onScreenHelp = [self.standardDefaults boolForKey:DefaultsOnScreenHelp];
    return _onScreenHelp;
}

#pragma mark - Location Geocoder Accuracy

@synthesize locationGeocoderAccuracy = _locationGeocoderAccuracy;

- (void)setLocationGeocoderAccuracy:(NSNumber *)locationGeocoderAccuracy
{
    _locationGeocoderAccuracy = locationGeocoderAccuracy;
    [self.standardDefaults setValue:locationGeocoderAccuracy forKey:DefaultsLocationGeocoderAccuracy];
    [self.standardDefaults synchronize];
}

- (NSNumber*)locationGeocoderAccuracy
{
    _locationGeocoderAccuracy = [self.standardDefaults valueForKey:DefaultsLocationGeocoderAccuracy];
    return _locationGeocoderAccuracy;
}

#pragma mark - Location Geocoder Timeout

@synthesize locationGeocoderTimeout = _locationGeocoderTimeout;

- (void)setLocationGeocoderTimeout:(NSNumber *)locationGeocoderTimeout
{
    _locationGeocoderTimeout = locationGeocoderTimeout;
    [self.standardDefaults setValue:locationGeocoderTimeout forKey:DefaultsLocationGeocoderTimeout];
    [self.standardDefaults synchronize];
}

- (NSNumber*)locationGeocoderTimeout
{
    _locationGeocoderTimeout = [self.standardDefaults valueForKey:DefaultsLocationGeocoderTimeout];
    return _locationGeocoderTimeout;
}

#pragma mark - Forecast Accuracy

@synthesize forecastAccuracy = _forecastAccuracy;

- (void)setForecastAccuracy:(NSNumber *)forecastAccuracy
{
    _forecastAccuracy = forecastAccuracy;
    [self.standardDefaults setValue:forecastAccuracy forKey:DefaultsForecastAccuracy];
    [self.standardDefaults synchronize];
}

- (NSNumber*)forecastAccuracy
{
    _forecastAccuracy = [self.standardDefaults valueForKey:DefaultsForecastAccuracy];
    return _forecastAccuracy;
}

#pragma mark - Forecast Validity

@synthesize forecastValidity = _forecastValidity;

- (void)setForecastValidity:(NSNumber *)forecastValidity
{
    _forecastValidity = forecastValidity;
    [self.standardDefaults setValue:_forecastValidity forKey:DefaultsForecastValidity];
    [self.standardDefaults synchronize];
}

- (NSNumber*)forecastValidity
{
    _forecastValidity = [self.standardDefaults valueForKey:DefaultsForecastValidity];
    return _forecastValidity;
}

#pragma mark - Forecast Unit Temperature

@synthesize forecastUnitTemperature = _forecastUnitTemperature;

- (void)setForecastUnitTemperature:(NSString *)forecastUnitTemperature
{
    _forecastUnitTemperature = forecastUnitTemperature;
    [self.standardDefaults setValue:forecastUnitTemperature forKey:DefaultsForecastUnitTemperature];
    [self.standardDefaults synchronize];
}

- (NSString*)forecastUnitTemperature
{
    _forecastUnitTemperature = [self.standardDefaults valueForKey:DefaultsForecastUnitTemperature];
    return _forecastUnitTemperature;
}

#pragma mark - Forecast Unit Windspeed

@synthesize forecastUnitWindspeed = _forecastUnitWindspeed;

- (void)setForecastUnitWindspeed:(NSString *)forecastUnitWindspeed
{
    _forecastUnitWindspeed = forecastUnitWindspeed;
    [self.standardDefaults setValue:forecastUnitWindspeed forKey:DefaultsForecastUnitWindspeed];
    [self.standardDefaults synchronize];
}

- (NSString*)forecastUnitWindspeed
{
    _forecastUnitWindspeed = [self.standardDefaults valueForKey:DefaultsForecastUnitWindspeed];
    return _forecastUnitWindspeed;
}

#pragma mark - Forecast Unit Precipitation

@synthesize forecastUnitPrecipitation = _forecastUnitPrecipitation;

- (void)setForecastUnitPrecipitation:(NSString *)forecastUnitPrecipitation
{
    _forecastUnitPrecipitation = forecastUnitPrecipitation;
    [self.standardDefaults setValue:forecastUnitPrecipitation forKey:DefaultsForecastUnitPrecipitation];
    [self.standardDefaults synchronize];
}

- (NSString*)forecastUnitPrecipitation
{
    _forecastUnitPrecipitation = [self.standardDefaults valueForKey:DefaultsForecastUnitPrecipitation];
    return _forecastUnitPrecipitation;
}

#pragma mark - Forecast Unit Pressure

@synthesize forecastUnitPressure = _forecastUnitPressure;

- (void)setForecastUnitPressure:(NSString *)forecastUnitPressure
{
    _forecastUnitPressure = forecastUnitPressure;
    [self.standardDefaults setValue:forecastUnitPressure forKey:DefaultsForecastUnitPressure];
    [self.standardDefaults synchronize];
}

- (NSString*)forecastUnitPressure
{
    _forecastUnitPressure = [self.standardDefaults valueForKey:DefaultsForecastUnitPressure];
    return _forecastUnitPressure;
}

#pragma mark - Forecast Unit Altitude

@synthesize forecastUnitAltitude = _forecastUnitAltitude;

- (void)setForecastUnitAltitude:(NSString *)forecastUnitAltitude
{
    _forecastUnitAltitude = forecastUnitAltitude;
    [self.standardDefaults setValue:forecastUnitAltitude forKey:DefaultsForecastUnitAltitude];
    [self.standardDefaults synchronize];
}

- (NSString*)forecastUnitAltitude
{
    _forecastUnitAltitude = [self.standardDefaults valueForKey:DefaultsForecastUnitAltitude];
    return _forecastUnitAltitude;
}

#pragma mark - Containers

- (NSDictionary*)dictionaryForKey:(NSString*)key
{
    __block NSDictionary* dict = nil;
    [[self preferenceArray] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSMultiValueSpecifier"] && [[element objectForKey:@"Key"] isEqualToString:key]) {
            
            NSArray* titlesArray = [element objectForKey:@"Titles"];
            NSArray* valuesArray = [element objectForKey:@"Values"];
            dict = [NSDictionary dictionaryWithObjects:valuesArray forKeys:titlesArray];
            *stop = YES;
        }
    }];
    return dict;
}

- (NSString*)elementTitleForKey:(NSString*)key
{
    __block NSString* title = nil;
    [[self preferenceArray] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSMultiValueSpecifier"] && [[element objectForKey:@"Key"] isEqualToString:key]) {
            
            title = [element objectForKey:@"Title"];
            *stop = YES;
        }
    }];
    return title;
}

- (NSArray*)valuesForKey:(NSString *)key
{
    __block NSArray* array = nil;
    [[self preferenceArray] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSMultiValueSpecifier"] && [[element objectForKey:@"Key"] isEqualToString:key]) {
            
            array = [element objectForKey:@"Values"];
            *stop = YES;
        }
    }];
    return array;
}

- (NSArray*)titlesForKey:(NSString*)key
{
    __block NSArray* array = nil;
    [[self preferenceArray] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSMultiValueSpecifier"] && [[element objectForKey:@"Key"] isEqualToString:key]) {
            
            array = [element objectForKey:@"Titles"];
            *stop = YES;
        }
    }];
    return array;
}

- (NSArray*)preferenceArray
{
    NSString* mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* settingsPropertyListPath = [mainBundlePath stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
    NSDictionary* settingsPropertyList = [NSDictionary dictionaryWithContentsOfFile:settingsPropertyListPath];
    
    return [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
}

- (NSString*)titleForValue:(id)value forKey:(NSString*)key
{
    NSArray* titles = [self titlesForKey:key];
    NSArray* values = [self valuesForKey:key];
    
    if (titles == nil || values == nil) {
        return key;
    }
    
    NSUInteger idx = [values indexOfObject:value];
    
    if (idx != NSNotFound) {
        return titles[idx];
    } else {
        return key;
    }
}

@end
