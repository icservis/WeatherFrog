//
//  ForecastFooter.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "ForecastFooter.h"
#import "Astro.h"
#import "Weather.h"

@interface ForecastFooter()

@property (nonatomic, weak) IBOutlet UILabel* moonPhase;
@property (nonatomic, weak) IBOutlet UILabel* tzAbbreviation;

@end

@implementation ForecastFooter

+ (CGFloat)forecastFooterHeight
{
    return 21.0f;
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

- (void)setAstro:(Astro *)astro
{
    _astro = astro;
    _moonPhase.text = astro.moonPhase;
}

@end
