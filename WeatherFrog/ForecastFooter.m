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

@property (nonatomic, weak) IBOutlet UILabel* sunRiseSet;
@property (nonatomic, weak) IBOutlet UILabel* moonPhase;
@property (nonatomic, weak) IBOutlet UILabel* tzAbbreviation;
@property (nonatomic, strong) NSMutableDictionary* localizationDict;
@property (nonatomic, strong) NSDateFormatter* localDateFormatter;

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
    [self.localDateFormatter setTimeZone:timeZone];
}

- (void)setAstro:(Astro *)astro
{
    _astro = astro;
    NSString* sunRise = [self.localDateFormatter stringFromDate:_astro.sunRise];
    NSString* sunSet = [self.localDateFormatter stringFromDate:_astro.sunSet];
    _sunRiseSet.text = [NSString stringWithFormat:@"%@: %@/%@", NSLocalizedString(@"Sun", nil), sunRise, sunSet];
    _moonPhase.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Moon", nil), [self.localizationDict objectForKey:astro.moonPhase]];
}

- (NSMutableDictionary*)localizationDict
{
    if (_localizationDict == nil) {
        _localizationDict = [[NSMutableDictionary alloc] init];
        [_localizationDict setObject:NSLocalizedString(@"New moon", nil) forKey:@"New moon"];
        [_localizationDict setObject:NSLocalizedString(@"Waxing crescent", nil) forKey:@"Waxing crescent"];
        [_localizationDict setObject:NSLocalizedString(@"First quarter", nil) forKey:@"First quarter"];
        [_localizationDict setObject:NSLocalizedString(@"Waxing gibbous", nil) forKey:@"Waxing gibbous"];
        [_localizationDict setObject:NSLocalizedString(@"Full moon", nil) forKey:@"Full moon"];
        [_localizationDict setObject:NSLocalizedString(@"Waning gibbous", nil) forKey:@"Waning gibbous"];
        [_localizationDict setObject:NSLocalizedString(@"Third quarter", nil) forKey:@"Third quarter"];
        [_localizationDict setObject:NSLocalizedString(@"Waning crescent", nil) forKey:@"Waning crescent"];
    }
    return _localizationDict;
}

- (NSDateFormatter*)localDateFormatter
{
    if (_localDateFormatter == nil) {
        _localDateFormatter = [[NSDateFormatter alloc] init];
        [_localDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_localDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return _localDateFormatter;
}

@end
