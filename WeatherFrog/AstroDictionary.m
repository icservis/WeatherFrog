//
//  AstroDictionary.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AstroDictionary.h"

@implementation AstroDictionary

@synthesize sunRise;
@synthesize sunSet;
@synthesize sunNeverRise;
@synthesize sunNeverSet;
@synthesize dayLength;
@synthesize noonAltitude;
@synthesize moonPhase;
@synthesize moonRise;
@synthesize moonSet;
@synthesize date;

- (NSString*)description
{
    return [NSString stringWithFormat:@"date: %@, sunRise: %@, sunSet: %@, noonAltitude: %@, moonPhase: %@, moonRise: %@, moonSet: %@", [self.date description], [self.sunRise description], [self.sunSet description], [self.noonAltitude description], [self.moonPhase description], [self.moonRise description], [self.moonSet description]];
}

@end
