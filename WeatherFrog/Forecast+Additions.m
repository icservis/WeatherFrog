//
//  Forecast+Additions.m
//  WeatherFrog
//
//  Created by Libor Kučera on 27.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "Forecast+Additions.h"
#import "WeatherDictionary.h"
#import "Weather.h"
#import "Astro.h"
#import "AstroDictionary.h"

@implementation Forecast (Additions)

- (NSArray*)sortedWeatherDataForPortrait
{
    NSMutableDictionary* days = [NSMutableDictionary new];
    
    static NSDateFormatter* localDateFormatter = nil;
    if (localDateFormatter == nil) {
        localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setDateFormat:@"g"]; // Modified Julian day. This is different from the conventional Julian day number in two regards. First, it demarcates days at local zone midnight, rather than noon GMT. Second, it is a local number; that is, it depends on the local time zone. It can be thought of as a single number that encompasses all the date-related fields.
    }
    [localDateFormatter setTimeZone:self.timezone];
    
    
    [self.weather enumerateObjectsUsingBlock:^(Weather* weather, NSUInteger idx, BOOL *stop) {
        
        NSString* day = [localDateFormatter stringFromDate:weather.timestamp];
        
        if ([days objectForKey:day] == nil) {
            
            NSMutableArray* hours = [NSMutableArray new];
            [hours addObject:weather];
            [days setObject:hours forKey:day];
            
        } else {
            
            NSMutableArray* hours = [days objectForKey:day];
            [hours addObject:weather];
        }
    }];
    
    //DDLogVerbose(@"days: %@", [days description]);
    
    NSArray *sortedKeys = [[days allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *sortedValues = [NSMutableArray array];
    for (NSString *key in sortedKeys)
        [sortedValues addObject: [days objectForKey: key]];
    
    //DDLogVerbose(@"sortedValues: %@", [sortedValues description]);
    return sortedValues;
}

- (NSArray*)sortedWeatherDataForLandscape
{
    NSArray* sortedData = [self.weather sortedArrayUsingComparator:^NSComparisonResult(Weather* obj1, Weather* obj2) {
        NSDate* firstTimestamp = obj1.timestamp;
        NSDate* secondTimestamp = obj2.timestamp;
        
        return  [firstTimestamp compare:secondTimestamp];
    }];
    
    NSMutableDictionary* pages = [NSMutableDictionary new];
    
    Weather* firstWeather = sortedData[0];
    NSDate* startTime = firstWeather.timestamp;
    
    [self.weather enumerateObjectsUsingBlock:^(Weather* weather, NSUInteger idx, BOOL *stop) {
        
        NSTimeInterval difference = [weather.timestamp timeIntervalSinceDate:startTime];
        float page_nr = floorf(difference/3600/LandscapeForecastConfigHours);
        NSNumber* page = [NSNumber numberWithFloat:page_nr];
        
        if ([pages objectForKey:page] == nil) {
            
            NSMutableArray* hours = [NSMutableArray new];
            [hours addObject:weather];
            [pages setObject:hours forKey:page];
            
        } else {
            
            NSMutableArray* hours = [pages objectForKey:page];
            [hours addObject:weather];
        }
    }];
    
    NSArray *sortedKeys = [[pages allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *sortedValues = [NSMutableArray array];
    for (NSString *key in sortedKeys)
        [sortedValues addObject: [pages objectForKey: key]];
    
    //DDLogVerbose(@"sortedValues: %@", [sortedValues description]);
    return sortedValues;
}

- (NSString*)description
{
    /*
    NSString* weather = @"";
    for (WeatherDictionary* dict in self.weather) {
        weather = [NSString stringWithFormat:@"%@\n%@", weather, [dict description]];
    }
    
    NSString* astro = @"";
    for (AstroDictionary* dict in self.astro) {
        astro = [NSString stringWithFormat:@"%@\n%@", astro, [dict description]];
    }
    
    
    return [NSString stringWithFormat:@"name: %@,\ntimestamp: %@,\nlatitude: %@,\nlongitude: %@,\naltitude: %@,\ntimezone: %@,\nvalidTill: %@,\nweather count: %i,\nastro count: %i, \nweather: %@,\nastro: %@\n", self.name, [NSString stringWithDate:self.timestamp], self.latitude, self.longitude, self.altitude, [self.timezone description], [NSString stringWithDate:self.validTill], [self.weather count], [self.astro count], weather, astro];
    */
    return [NSString stringWithFormat:@"name: %@,\ntimestamp: %@,\nlatitude: %@,\nlongitude: %@,\naltitude: %@,\ntimezone: %@,\nvalidTill: %@,\nweather count: %i,\nastro count: %i", self.name, [NSString stringWithDate:self.timestamp], self.latitude, self.longitude, self.altitude, [self.timezone description], [NSString stringWithDate:self.validTill], [self.weather count], [self.astro count]];
}

@end
