//
//  ForecastHeader.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "ForecastHeader.h"
#import "Weather.h"

@interface ForecastHeader()

@property (nonatomic, weak) IBOutlet UILabel* tzAbbreviation;

@end

@implementation ForecastHeader

+ (CGFloat)forecastHeaderHeight
{
    return 1.0f;
}

- (void)setWeather:(Weather *)weather
{
    _weather = weather;
}

- (void)setTimeZone:(NSTimeZone *)timeZone
{
    _timeZone = timeZone;
    _tzAbbreviation.text = [_timeZone abbreviationForDate:_weather.timestamp];
}


@end
