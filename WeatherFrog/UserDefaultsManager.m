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
        
        NSArray* preferenceArray = [self elementsList];
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

#pragma mark - Notifications

@synthesize notifications = _notifications;

- (void)setNotifications:(NSNumber *)notifications
{
    _notifications = notifications;
    [self.standardDefaults setValue:notifications forKey:DefaultsNotifications];
    [self.standardDefaults synchronize];
}

- (NSNumber*)notifications
{
    _notifications = [self.standardDefaults valueForKey:DefaultsNotifications];
    return _notifications;
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

#pragma mark - Last Notification Symbol

@synthesize lastNotificationSymbol = _lastNotificationSymbol;

- (void)setLastNotificationSymbol:(NSNumber *)lastNotificationSymbol
{
    _lastNotificationSymbol = lastNotificationSymbol;
    [self.standardDefaults setValue:lastNotificationSymbol forKey:DefaultsLastNotificationSymbol];
    [self.standardDefaults synchronize];
}

- (NSNumber*)lastNotificationSymbol
{
    _lastNotificationSymbol = [self.standardDefaults valueForKey:DefaultsLastNotificationSymbol];
    return _lastNotificationSymbol;
}

#pragma mark - Ad Free Mode

@synthesize adFreeMode = _adFreeMode;

- (void)setAdFreeMode:(BOOL)adFreeMode
{
    _adFreeMode = adFreeMode;
    [self.standardDefaults setBool:adFreeMode forKey:DefaultsAdFreeMode];
    [self.standardDefaults synchronize];
}

- (BOOL)adFreeMode
{
    _adFreeMode = [self.standardDefaults boolForKey:DefaultsAdFreeMode];
    return _onScreenHelp;
}

#pragma mark - Full Notification Mode

@synthesize fullNotificationMode = _fullNotificationMode;

- (void)setFullNotificationMode:(BOOL)fullNotificationMode
{
    _fullNotificationMode = fullNotificationMode;
    [self.standardDefaults setBool:fullNotificationMode forKey:DefaultsFullNotificationMode];
    [self.standardDefaults synchronize];
}

- (BOOL)fullNotificationMode
{
    _fullNotificationMode = [self.standardDefaults boolForKey:DefaultsFullNotificationMode];
    return _fullNotificationMode;
}

#pragma mark - Helpers

- (NSArray*)elementsList
{
    NSString* mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* settingsPropertyListPath = [mainBundlePath stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
    NSDictionary* settingsPropertyList = [NSDictionary dictionaryWithContentsOfFile:settingsPropertyListPath];
    
    return [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
}

- (NSArray*)elementsSections
{
    NSMutableDictionary* section;
    NSMutableArray* sections = [NSMutableArray array];
    NSArray* elementsList = [self elementsList];
    if (elementsList != nil && elementsList.count > 0) {
        NSDictionary* firstElement = elementsList[0];
        if (![[firstElement objectForKey:@"Type"] isEqualToString:@"PSGroupSpecifier"]) {
            section = [NSMutableDictionary dictionary];
            [section setObject:@"" forKey:@"Title"];
            [section setObject:[NSMutableArray array] forKey:@"Elements"];
            [sections addObject:section];
        }
    }
    for (NSDictionary* element in elementsList) {
        
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSGroupSpecifier"]) {
            // new section
            section = [NSMutableDictionary dictionary];
            [section setObject:[element objectForKey:@"Title"] forKey:@"Title"];
            [section setObject:[NSMutableArray array] forKey:@"Elements"];
            [sections addObject:section];
            
        } else {
            // member of current section
            section = [sections lastObject];
            NSMutableArray* elements = [section objectForKey:@"Elements"];
            [elements addObject:element];
            
        }
    }
    DDLogVerbose(@"sections: %@", [sections description]);
    return sections;
}

- (NSString*)elementTitleForKey:(NSString*)key
{
    __block NSString* title = nil;
    [[self elementsList] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Key"] isEqualToString:key]) {
            
            title = [element objectForKey:@"Title"];
            *stop = YES;
        }
    }];
    return title;
}

- (id)elementValueForKey:(NSString*)key
{
    if ([key isEqualToString:DefaultsNotifications]) {
        return [self notifications];
    }
    if ([key isEqualToString:DefaultsDisplayMode]) {
        return [self displayMode];
    }
    if ([key isEqualToString:DefaultsLocationGeocoderAccuracy]) {
        return [self locationGeocoderAccuracy];
    }
    if ([key isEqualToString:DefaultsLocationGeocoderTimeout]) {
        return [self locationGeocoderTimeout];
    }
    if ([key isEqualToString:DefaultsForecastAccuracy]) {
        return [self forecastAccuracy];
    }
    if ([key isEqualToString:DefaultsForecastValidity]) {
        return [self forecastValidity];
    }
    if ([key isEqualToString:DefaultsForecastUnitTemperature]) {
        return [self forecastUnitTemperature];
    }
    if ([key isEqualToString:DefaultsForecastUnitWindspeed]) {
        return [self forecastUnitWindspeed];
    }
    if ([key isEqualToString:DefaultsForecastUnitPrecipitation]) {
        return [self forecastUnitPrecipitation];
    }
    if ([key isEqualToString:DefaultsForecastUnitPressure]) {
        return [self forecastUnitPressure];
    }
    if ([key isEqualToString:DefaultsForecastUnitAltitude]) {
        return [self forecastUnitAltitude];
    }
    return nil;
}

- (NSString*)titleOfMultiValue:(id)value forKey:(NSString*)key
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

- (NSString*)titleOfSliderValue:(id)value forKey:(NSString*)key
{
    DDLogVerbose(@"%@", [[self elementValueForKey:key] description]);
    
    NSUInteger idx = [[self elementValueForKey:key] integerValue];
    NSMutableArray* titles = [NSMutableArray array];
    
    if ([key isEqualToString:DefaultsNotifications]) {
        [titles addObject:NSLocalizedString(@"None", nil)];
        [titles addObject:NSLocalizedString(@"Low", nil)];
        [titles addObject:NSLocalizedString(@"Middle", nil)];
        [titles addObject:NSLocalizedString(@"High", nil)];
        [titles addObject:NSLocalizedString(@"All", nil)];
    }
    
    if (titles[idx] != nil) {
        return (NSString*)titles[idx];
    }
    return [NSString stringWithFormat:@"%@: %i", NSLocalizedString(@"Level", nil), idx];
}

- (NSArray*)valuesForKey:(NSString *)key
{
    __block NSArray* array = nil;
    [[self elementsList] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
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
    [[self elementsList] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSMultiValueSpecifier"] && [[element objectForKey:@"Key"] isEqualToString:key]) {
            
            array = [element objectForKey:@"Titles"];
            *stop = YES;
        }
    }];
    return array;
}

- (NSNumber*)minValueForKey:(NSString *)key
{
    __block NSNumber* minValue = nil;
    [[self elementsList] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSSliderSpecifier"] && [[element objectForKey:@"Key"] isEqualToString:key]) {
            
            minValue = [element objectForKey:@"MinimumValue"];
            *stop = YES;
        }
    }];
    return minValue;
}

- (NSNumber*)maxValueForKey:(NSString *)key
{
    __block NSNumber* maxValue = nil;
    [[self elementsList] enumerateObjectsUsingBlock:^(NSDictionary* element, NSUInteger idx, BOOL *stop) {
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSSliderSpecifier"] && [[element objectForKey:@"Key"] isEqualToString:key]) {
            
            maxValue = [element objectForKey:@"MaximumValue"];
            *stop = YES;
        }
    }];
    return maxValue;
}

@end
