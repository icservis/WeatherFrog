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

@protocol ForecastManagerDelegate <NSObject>

- (void)forecastManager:(id)manager didFinishProcessingForecast:(Forecast*)forecast;
- (void)forecastManager:(id)manager didFailProcessingForecast:(Forecast*)forecast error:(NSError*)error;

@optional

- (void)forecastManager:(id)manager changingStatusForecast:(ForecastStatus)status;
- (void)forecastManager:(id)manager updatingProgressProcessingForecast:(float)progress;

- (void)forecastManager:(id)manager didFinishFetchingElevation:(float)elevation;
- (void)forecastManager:(id)manager didFinishFetchingTimezone:(NSTimeZone*)timezone;
- (void)forecastManager:(id)manager didFinishFetchingAstro:(NSOrderedSet*)astroData;
- (void)forecastManager:(id)manager didFinishFetchingWeather:(NSOrderedSet*)weatherData;

@end

@interface ForecastManager : NSObject

@property (nonatomic, weak) id <ForecastManagerDelegate> delegate;
@property (nonatomic, readonly) ForecastStatus status;
@property (nonatomic, readonly) float progress;

- (void)forecastWithPlacemark:(CLPlacemark*)placemark timezone:(NSTimeZone*)timezone forceUpdate:(BOOL)force;

@end
