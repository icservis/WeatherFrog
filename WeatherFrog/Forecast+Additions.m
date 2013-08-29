//
//  Forecast+Additions.m
//  WeatherFrog
//
//  Created by Libor Kučera on 27.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Forecast+Additions.h"
#import "WeatherDictionary.h"
#import "AstroDictionary.h"

@implementation Forecast (Additions)

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
