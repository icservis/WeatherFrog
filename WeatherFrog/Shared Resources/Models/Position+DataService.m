//
//  Position+DataService.m
//  WeatherFrog
//
//  Created by Libor Kučera on 02.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "Position+DataService.h"

@implementation Position (DataService)

- (CLLocation*)location
{
    return [[CLLocation alloc] initWithCoordinate:[self coordinate] altitude:[self.altitude floatValue] horizontalAccuracy:[self.horizontalAccuracy floatValue] verticalAccuracy:[self.verticalAccuracy floatValue] course:0 speed:0 timestamp:self.timestamp];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (Forecast*)forecast
{
    return [[self validForecasts] firstObject];
}

- (NSArray*)validForecasts
{
    NSPredicate* filterPredicate = [NSPredicate predicateWithBlock:^BOOL(Forecast* forecast, NSDictionary *bindings) {
        return YES;
    }];
    NSSet* validForecasts = [self.forecasts filteredSetUsingPredicate:filterPredicate];
    NSArray* sortedForecasts = [[validForecasts allObjects] sortedArrayUsingComparator:^NSComparisonResult(Forecast* obj1, Forecast* obj2) {
        return [obj2.validForDate compare:obj1.validForDate];
    }];
    
    return sortedForecasts;
}

@end
