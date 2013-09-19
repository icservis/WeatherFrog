//
//  Forecast+Additions.m
//  WeatherFrog
//
//  Created by Libor Kučera on 27.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

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
        [localDateFormatter setDateFormat:@"D"];
    }
    [localDateFormatter setTimeZone:self.timezone];
    
    
    [self.weather enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Weather* weather = (Weather*)obj;
        
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
    
    return sortedValues;
}

- (NSArray*)sortedWeatherDataForLandscape
{
    return nil;
}

- (NSString*)description
{
    NSString* weather = @"";
    for (WeatherDictionary* dict in self.weather) {
        weather = [NSString stringWithFormat:@"%@\n%@", weather, [dict description]];
    }
    
    NSString* astro = @"";
    for (AstroDictionary* dict in self.astro) {
        astro = [NSString stringWithFormat:@"%@\n%@", astro, [dict description]];
    }
    
    
    return [NSString stringWithFormat:@"name: %@,\ntimestamp: %@,\nlatitude: %@,\nlongitude: %@,\naltitude: %@,\ntimezone: %@,\nvalidTill: %@,\nweather count: %i,\nastro count: %i, \nweather: %@,\nastro: %@\n", self.name, [NSString stringWithDate:self.timestamp], self.latitude, self.longitude, self.altitude, [self.timezone description], [NSString stringWithDate:self.validTill], [self.weather count], [self.astro count], weather, astro];
}

@end
