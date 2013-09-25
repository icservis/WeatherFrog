//
//  ForecastManager.h
//  WeatherFrog
//
//  Created by Libor Kučera on 27.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ForecastStatusIdle,
    ForecastStatusActive,
    ForecastStatusFetchingElevation,
    ForecastStatusFetchedElevation,
    ForecastStatusFetchingTimezone,
    ForecastStatusFetchedTimezone,
    ForecastStatusFetchingSolarData,
    ForecastStatusFetchedSolarData,
    ForecastStatusFetchingWeatherData,
    ForecastStatusFetchedWeatherData,
    ForecastStatusSaving,
    ForecastStatusCompleted,
    ForecastStatusFailed,
    ForecastStatusLoaded
} ForecastStatus;

@class Forecast;
@class ForecastManager;

@protocol ForecastManagerDelegate <NSObject>

- (void)forecastManager:(ForecastManager*)manager didFinishProcessingForecast:(Forecast*)forecast;
- (void)forecastManager:(ForecastManager*)manager didFailProcessingForecast:(Forecast*)forecast error:(NSError*)error;

@optional

- (void)forecastManager:(ForecastManager*)manager didStartFetchingForecast:(ForecastStatus)status;

- (void)forecastManager:(ForecastManager*)manager changingStatusForecast:(ForecastStatus)status;
- (void)forecastManager:(ForecastManager*)manager updatingProgressProcessingForecast:(float)progress;

- (void)forecastManager:(ForecastManager*)manager didFinishFetchingElevation:(float)elevation;
- (void)forecastManager:(ForecastManager*)manager didFinishFetchingTimezone:(NSTimeZone*)timezone;
- (void)forecastManager:(ForecastManager*)manager didFinishFetchingAstro:(NSOrderedSet*)astroData;
- (void)forecastManager:(ForecastManager*)manager didFinishFetchingWeather:(NSOrderedSet*)weatherData;

@end

@interface ForecastManager : NSObject

@property (nonatomic, weak) id <ForecastManagerDelegate> delegate;
@property (nonatomic, readonly) ForecastStatus status;
@property (nonatomic, readonly) float progress;

- (Forecast*)lastForecast;

- (void)forecastWithPlacemark:(CLPlacemark*)placemark timezone:(NSTimeZone*)timezone forceUpdate:(BOOL)force;
- (void)forecastWithPlacemark:(CLPlacemark*)placemark timezone:(NSTimeZone*)timezone successWithNewData:(void (^)(Forecast* forecast))newData withLoadedData:(void (^)(Forecast* forecast))loadedData failure:(void (^)())failure;

@end
