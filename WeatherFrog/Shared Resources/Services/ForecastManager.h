//
//  ForecastManager.h
//  WeatherFrog
//
//  Created by Libor Kučera on 02.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

@import CoreLocation;

#import "Position+DataService.h"
#import "Forecast+DataService.h"

static NSString* const kForecastManagerDidUpdateCurrentLocationData = @"FORECASTMANAGER_DID_UPDATE_CURRENT_LOCATION_DATA";

@interface ForecastManager : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (ForecastManager*)sharedManager;

@property (nonatomic, assign) double progress;

- (void)updateForecastForPosition:(Position*)position withCompletionBlock:(void(^)(BOOL updated, NSError* error))completionBlock;

@end
