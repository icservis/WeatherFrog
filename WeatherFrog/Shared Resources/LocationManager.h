//
//  LocationManager.h
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Location.h"

@interface LocationManager : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (LocationManager*)sharedManager;

- (CLLocation*)currentLocation;

@end
