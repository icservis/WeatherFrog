//
//  Forecast+Additions.h
//  WeatherFrog
//
//  Created by Libor Kučera on 27.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Forecast.h"

@interface Forecast (Additions)

- (NSString*)description;
- (NSArray*)sortedWeatherDataForPortrait;
- (NSArray*)sortedWeatherDataForLandscape;

@end
