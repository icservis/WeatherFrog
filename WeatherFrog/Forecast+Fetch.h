//
//  Forecast+Fetch.h
//  WeatherFrog
//
//  Created by Libor Kučera on 24.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Forecast.h"

@interface Forecast (Fetch)

+ (void)fetchWithPlacemark:(CLPlacemark*)placemark forceUpdate:(BOOL)force success:(void (^)(Forecast* forecast))success failure:(void (^)(NSError *error))failure progress:(void (^)(float progress))failure;

@end
