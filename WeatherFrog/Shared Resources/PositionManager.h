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

@property (nonatomic, strong, readonly) CLLocation* currentLocation;
@property (nonatomic, strong, readonly) CLPlacemark* currentPlacemark;
@property (nonatomic, strong, readonly) Position* currentPosition;

/**
 * gets singleton object.
 * @return singleton
 */

+ (PositionManager*)sharedManager;

// Current Location

- (void)startMonitoringCurrentLocation;
- (void)stopMonitoringCurrentLocation;

- (Position*)positionForPlacemark:(CLPlacemark*)placemark;

@end
