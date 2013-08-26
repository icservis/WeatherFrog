//
//  Location+Store.h
//  WeatherFrog
//
//  Created by Libor Kučera on 24.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Location.h"

@class Forecast;

@interface Location (Store)

+ (Location*)locationWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate altitude:(CLLocationDistance)altitude timezone:(NSTimeZone*)timezone placemark:(CLPlacemark*)placemark;

+ (Location*)locationforForecast:(Forecast*)forecast;
+ (Location*)locationforPlacemark:(CLPlacemark*)placemark;

@end
