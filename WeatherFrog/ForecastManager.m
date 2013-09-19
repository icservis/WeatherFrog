//
//  ForecastManager.m
//  WeatherFrog
//
//  Created by Libor Kučera on 27.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "ForecastManager.h"
#import "Forecast.h"
#import "Weather.h"
#import "WeatherDictionary.h"
#import "Astro.h"
#import "AstroDictionary.h"
#import "YrApiService.h"
#import "GoogleApiService.h"

@interface ForecastManager ()

@property (nonatomic, readwrite) ForecastStatus status;
@property (nonatomic, readwrite) float progress;

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) CLPlacemark* placemark;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) CLLocationDistance altitude;
@property (nonatomic, strong) NSTimeZone* timezone;
@property (nonatomic, strong) NSDate* timestamp;
@property (nonatomic, strong) NSDate* validTill;
@property (nonatomic, strong) NSArray* weatherData;
@property (nonatomic, strong) NSArray* astroData;

@end

@implementation ForecastManager

@synthesize name = _name;
@synthesize placemark = _placemark;
@synthesize coordinate = _coordinate;
@synthesize altitude = _altitude;
@synthesize timezone = _timezone;
@synthesize timestamp = _timestamp;
@synthesize validTill = _validTill;
@synthesize weatherData = _weatherData;
@synthesize astroData = _astroData;

- (void)setStatus:(ForecastStatus)status
{
    _status = status;
    if ([self.delegate respondsToSelector:@selector(forecastManager:changingStatusForecast:)]) {
        [self.delegate forecastManager:self changingStatusForecast:status];
    }
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if ([self.delegate respondsToSelector:@selector(forecastManager:updatingProgressProcessingForecast:)]) {
        [self.delegate forecastManager:self updatingProgressProcessingForecast:progress];
    }
}

#pragma mark - logic

- (void)forecastWithPlacemark:(CLPlacemark*)placemark timezone:(NSTimeZone*)timezone forceUpdate:(BOOL)force
{
    DDLogInfo(@"force: %d", force);
    DDLogVerbose(@"forecastWithPlacemark: %@, timezone: %@, force: %d", [placemark description], [timezone description], force);
    
    [self instantiateForecastWithPlacemark:placemark timezone:timezone];
    
    Forecast* forecast;
    
    if (force == NO) {
        
        forecast = [self findForecastForPlacemark:placemark];
    }
    
    if (forecast != nil) {
        
        [self loadedForecast:forecast];
        
    } else {
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        if ([appDelegate isHostActive]) {
            
            [self startFetching];
            
            if (self.altitude == 0) {
                [self fetchElevation];
            } else if (self.timezone == nil) {
                [self fetchTimeZone];
            } else {
                [self fetchAstroData];
            }
            
        } else {
            
            NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"Network connection not available", nil), @"localizedDescription", nil];
            NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:dict];
            
            [self failedForecastWithError:error];
            
        }
    }
}

- (void)forecastWithPlacemark:(CLPlacemark *)placemark timezone:(NSTimeZone *)timezone successWithNewData:(void (^)(Forecast *))newData withLoadedData:(void (^)(Forecast *))loadedData failure:(void (^)())failure
{
    DDLogInfo(@"forecastWithPlacemark");
    [self instantiateForecastWithPlacemark:placemark timezone:timezone];
    Forecast* forecast = [self findForecastForPlacemark:placemark];
    
    if (forecast != nil) {
        
        [self loadedForecast:forecast];
        loadedData(forecast);
        return;
    }
    
    self.status = ForecastStatusFetchingSolarData;
    [[YrApiService sharedService] astroDatatWithLocation:placemark.location success:^(NSArray *solarData) {
        
        self.progress = 0.6f;
        self.status = ForecastStatusFetchedSolarData;
        self.astroData = solarData;
        
        self.status = ForecastStatusFetchingWeatherData;
        [[YrApiService sharedService] weatherDatatWithLocation:placemark.location success:^(NSArray *weatherData) {
            
            self.progress = 0.8f;
            self.status = ForecastStatusFetchedWeatherData;
            self.weatherData = weatherData;
            
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext* currentContext = appDelegate.defaultContext;
            
            Forecast* forecast = [self saveForecastInContext:currentContext];
            newData(forecast);
            
            /*
            DDLogInfo(@"Saving forecast");
            
            [currentContext saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                self.progress = 1.0f;
                
                if (error == nil) {
                    
                    DDLogInfo(@"Forecast saved");
                    newData(forecast);
                    
                } else {
                    
                    failure();
                }
            }];
            */
            
        } failure:^(NSError *error) {
            
            self.progress = 1.0f;
            failure();
        }];
        
        
    } failure:^(NSError *error) {
        
        self.progress = 1.0f;
        failure();
    }];
}

#pragma mark - helpers

- (Forecast*)findForecastForPlacemark:(CLPlacemark*)placemark
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* currentContext = appDelegate.defaultContext;
    NSPredicate* findPredicate = [NSPredicate predicateWithFormat:@"validTill > %@", [NSDate date]];
    NSArray* forecasts = [Forecast findAllWithPredicate:findPredicate inContext:currentContext];
    
    if (forecasts != nil) {
        
        CLLocation* placemarkLocation = [[CLLocation alloc] initWithCoordinate:placemark.location.coordinate altitude:placemark.location.altitude horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:placemark.location.timestamp];
        
        NSMutableArray* availableForecasts = [NSMutableArray array];
        for (Forecast* forecast in forecasts) {
            CLLocation* forecastLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake([forecast.latitude doubleValue], [forecast.longitude doubleValue]) altitude:[forecast.altitude floatValue] horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:forecast.timestamp];
            
            NSNumber* forecastAccuracy = [[UserDefaultsManager sharedDefaults] forecastAccuracy];
            if ([forecastLocation distanceFromLocation:placemarkLocation] <= [forecastAccuracy floatValue]) {
                [availableForecasts addObject:forecast];
            }
        }
        
        if (availableForecasts.count > 0) {
            
            NSArray* sortedForecasts;
            sortedForecasts = [availableForecasts sortedArrayUsingComparator:^NSComparisonResult(Forecast* obj1, Forecast* obj2) {
                NSDate* firstTimestamp = obj1.timestamp;
                NSDate* secondTimestamp = obj2.timestamp;
                
                return  [secondTimestamp compare:firstTimestamp];
            }];
            
            return sortedForecasts[0];
            
        } else {
            
            return nil;
        }
    }
    
    return nil;
}

#pragma mark - elements

- (void)startFetching
{
    if ([self.delegate respondsToSelector:@selector(forecastManager:didStartFetchingForecast:)]) {
        [self.delegate forecastManager:self didStartFetchingForecast:self.status];
    }
}

- (void)fetchElevation
{
    self.status = ForecastStatusFetchingElevation;
    [[GoogleApiService sharedService] elevationWithCoordinate:self.coordinate success:^(float elevation) {
        
        self.progress = 0.2f;
        self.status = ForecastStatusFetchedElevation;
        self.altitude = elevation;
        if ([self.delegate respondsToSelector:@selector(forecastManager:didFinishFetchingElevation:)]) {
            [self.delegate forecastManager:self didFinishFetchingElevation:elevation];
        }
        [self fetchTimeZone];
        
    } failure:^{
        
        [self fetchTimeZone];
    }];
}

- (void)fetchTimeZone
{
    self.status = ForecastStatusFetchingTimezone;
    [[GoogleApiService sharedService] timezoneWithCoordinate:self.coordinate success:^(NSString *timezoneName) {
        
        self.progress = 0.4f;
        self.status = ForecastStatusFetchedTimezone;
        self.timezone = [NSTimeZone timeZoneWithName:timezoneName];
        if ([self.delegate respondsToSelector:@selector(forecastManager:didFinishFetchingTimezone:)]) {
            [self.delegate forecastManager:self didFinishFetchingTimezone:self.timezone];
        }
        [self fetchAstroData];
        
    } failure:^{
        
        [self fetchAstroData];
    }];
}

- (void)fetchAstroData
{
    CLLocation* location = [[CLLocation alloc] initWithCoordinate:self.coordinate altitude:self.altitude horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:self.timestamp];
    
    self.status = ForecastStatusFetchingSolarData;
    [[YrApiService sharedService] astroDatatWithLocation:location success:^(NSArray *solarData) {
        
        self.progress = 0.6f;
        self.status = ForecastStatusFetchedSolarData;
        self.astroData = solarData;
        [self fetchWeatherData];
        
    } failure:^(NSError *error) {
        
        [self fetchWeatherData];
    }];
}

- (void)fetchWeatherData
{
    CLLocation* location = [[CLLocation alloc] initWithCoordinate:self.coordinate altitude:self.altitude horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:self.timestamp];
    
    self.status = ForecastStatusFetchingWeatherData;
    [[YrApiService sharedService] weatherDatatWithLocation:location success:^(NSArray *weatherData) {
        
        self.progress = 0.8f;
        self.status = ForecastStatusFetchedWeatherData;
        self.weatherData = weatherData;
        [self completedForecast];
        
    } failure:^(NSError *error) {
        
        self.progress = 1.0f;
        [self failedForecastWithError:error];
    }];
}

#pragma mark - states

- (void)instantiateForecastWithPlacemark:(CLPlacemark*)placemark timezone:(NSTimeZone*)timezone
{
    self.name = [placemark title];
    self.placemark = placemark;
    self.coordinate = placemark.location.coordinate;
    self.altitude = placemark.location.altitude;
    self.timezone = timezone;
    self.timestamp = [NSDate date];
    self.validTill = [NSDate dateWithTimeIntervalSinceNow:3*86400];
    self.weatherData = nil;
    self.astroData = nil;
    
    self.progress = 0.0f;
    self.status = ForecastStatusActive;
}

- (Forecast*)saveForecastInContext:(NSManagedObjectContext*)context
{
    Forecast* forecast = [Forecast createInContext:context];
    forecast.name = self.name;
    forecast.placemark = self.placemark;
    forecast.latitude = [NSNumber numberWithDouble:self.coordinate.latitude];
    forecast.longitude = [NSNumber numberWithDouble:self.coordinate.longitude];
    forecast.altitude = [NSNumber numberWithFloat:self.altitude];
    forecast.timezone = self.timezone;
    forecast.timestamp = self.timestamp;
    
    WeatherDictionary* lastWeatherData = [self.weatherData lastObject];
    if ([self.validTill compare:lastWeatherData.timestamp] == NSOrderedAscending) {
        forecast.validTill = lastWeatherData.timestamp;
    }
    
    [self.weatherData enumerateObjectsUsingBlock:^(WeatherDictionary* weatherDict, NSUInteger idx, BOOL *stop) {
        
        Weather* weather = [Weather createInContext:context];
        weather.temperature = weatherDict.temperature;
        weather.windDirection = weatherDict.windDirection;
        weather.windSpeed = weatherDict.windSpeed;
        weather.windScale = weatherDict.windScale;
        weather.humidity = weatherDict.humidity;
        weather.pressure = weatherDict.pressure;
        weather.cloudiness = weatherDict.cloudiness;
        weather.fog = weatherDict.fog;
        weather.lowClouds = weatherDict.lowClouds;
        weather.mediumClouds = weatherDict.mediumClouds;
        weather.highClouds = weatherDict.highClouds;
        weather.precipitation1h = weatherDict.precipitation1h;
        weather.precipitation2h = weatherDict.precipitation2h;
        weather.precipitation3h = weatherDict.precipitation3h;
        weather.precipitation6h = weatherDict.precipitation6h;
        weather.timestamp = weatherDict.timestamp;
        weather.symbol1h = weatherDict.symbol1h;
        weather.symbol2h = weatherDict.symbol2h;
        weather.symbol3h = weatherDict.symbol3h;
        weather.symbol6h = weatherDict.symbol6h;
        weather.created = weatherDict.created;
        weather.validTill = weatherDict.validTill;
        weather.created = weatherDict.created;
        weather.isNight = [NSNumber numberWithBool:[self isTimestampNight:weatherDict.timestamp forAstroData:self.astroData]];
        weather.forecast = forecast;
        
    }];
    
    
    [self.astroData enumerateObjectsUsingBlock:^(AstroDictionary* astroDict, NSUInteger idx, BOOL *stop) {
        
        Astro* astro = [Astro createInContext:context];
        astro.sunRise = astroDict.sunRise;
        astro.sunSet = astroDict.sunSet;
        astro.sunNeverRise = astroDict.sunNeverRise;
        astro.sunNeverSet = astroDict.sunNeverSet;
        astro.dayLength = astroDict.dayLength;
        astro.noonAltitude = astroDict.noonAltitude;
        astro.moonPhase = astroDict.moonPhase;
        astro.moonRise = astroDict.moonRise;
        astro.moonSet = astroDict.moonSet;
        astro.date = astroDict.date;
        astro.forecast = forecast;
        
    }];
    
    return forecast;
}

- (void)completedForecast
{
    self.status = ForecastStatusSaving;
    
    DDLogVerbose(@"Saving forecast");
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* currentContext = appDelegate.defaultContext;
    
    Forecast* forecast = [self saveForecastInContext:currentContext];
    self.progress = 1.0f;
    self.status = ForecastStatusCompleted;
    [self.delegate forecastManager:self didFinishProcessingForecast:forecast];
    
    DDLogInfo(@"Forecast saved");
    
    
    /*
    __block Forecast* blockForecast;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            blockForecast = [self saveForecastInContext:localContext];
            
        } completion:^(BOOL success, NSError *error) {
            
            self.progress = 1.0f;
            
            if (error == nil) {
                
                DDLogInfo(@"Forecast saved");
                self.status = ForecastStatusCompleted;
                [self.delegate forecastManager:self didFinishProcessingForecast:blockForecast];
                
            } else {
                
                [self failedForecastWithError:error];
            }
            
        }];
        
    } else {
        
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            
            blockForecast = [self saveForecastInContext:localContext];
            
        } completion:^(BOOL success, NSError *error) {
            
            self.progress = 1.0f;
            
            if (error == nil) {
                
                DDLogInfo(@"Forecast saved");
                self.status = ForecastStatusCompleted;
                [self.delegate forecastManager:self didFinishProcessingForecast:blockForecast];
                
            } else {
                
                [self failedForecastWithError:error];
            }
            
        }];
        
    }
     */
}

- (void)loadedForecast:(Forecast*)forecast
{
    DDLogInfo(@"Forecast loaded");
    self.progress = 1.0f;
    self.status = ForecastStatusLoaded;
    [self.delegate forecastManager:self didFinishProcessingForecast:forecast];
}

- (void)failedForecastWithError:(NSError*)error
{
    DDLogError(@"Forecast failed: %@", [error description]);
    self.progress = 1.0f;
    self.status = ForecastStatusFailed;
    [self.delegate forecastManager:self didFailProcessingForecast:nil error:error];
}

#pragma mark - support functions

- (BOOL)isTimestampNight:(NSDate*)timestamp forAstroData:(NSArray*)astroData
{
    BOOL _isNight = NO;
    
    if (timestamp == nil) {
        return _isNight;
    }
    
    static Astro* _foundAstro = nil;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:timestamp];
    [components setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate* date = [calendar dateFromComponents:components];
    
    if (_foundAstro == nil || [_foundAstro.date compare:date] != NSOrderedSame) {
        
        [astroData enumerateObjectsUsingBlock:^(Astro* astro, NSUInteger idx, BOOL *stop) {
            if ([astro.date isEqual:date]) {
                _foundAstro = astro;
                *stop = YES;
            }
        }];
    }

    if (_foundAstro != nil) {
        
        if ([timestamp compare:_foundAstro.sunRise] == NSOrderedAscending || [timestamp compare:_foundAstro.sunSet] == NSOrderedDescending || [_foundAstro.sunNeverRise isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            _isNight = YES;
        }
    }
    
    return _isNight;
}

@end
