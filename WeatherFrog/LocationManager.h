//
//  LocationManager.h
//  WeatherFrog
//
//  Created by Libor Kučera on 24.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Location;
@class Forecast;

@interface LocationManager : NSObject

- (Location*)locationWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate altitude:(CLLocationDistance)altitude timezone:(NSTimeZone*)timezone placemark:(CLPlacemark*)placemark;
- (void)deleteLocation:(Location*)location;
- (void)deleteObsoleteLocations;

- (Location*)locationforForecast:(Forecast*)forecast;
- (Location*)locationforPlacemark:(CLPlacemark*)placemark withTimezone:(NSTimeZone*)timezone;

@end
