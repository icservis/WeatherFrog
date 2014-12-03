//
//  LocationManager.h
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

@import CoreLocation;

#import "Position+DataService.h"
#import "Forecast+DataService.h"
#import "CLPlacemark+MKAnnotationDelegate.h"

@interface PositionManager : NSObject

/**
 * gets singleton object.
 * @return singleton
 */

+ (PositionManager*)sharedManager;

- (Position*)positionForPlacemark:(CLPlacemark*)placemark timezoneId:(NSString*)timezoneId;

@end
