//
//  Forecast+Additions.m
//  WeatherFrog
//
//  Created by Libor Kučera on 27.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Forecast+Additions.h"

@implementation Forecast (Additions)

- (NSString*)description
{
    return [NSString stringWithFormat:@"name: %@,\ntimestamp: %@,\nlatitude: %@,\nlongitude: %@,\naltitude: %@,\ntimezone: %@,\nvalidTill: %@,\nweather count: %i,\nastro count: %i", self.name, [NSString stringWithDate:self.timestamp], self.latitude, self.longitude, self.altitude, [self.timezone description], [NSString stringWithDate:self.validTill], [self.weather count], [self.astro count]];
}

@end
