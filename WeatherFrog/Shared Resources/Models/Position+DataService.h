//
//  Position+DataService.h
//  WeatherFrog
//
//  Created by Libor Kučera on 02.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "Position.h"
#import "Forecast+DataService.h"

@interface Position (DataService)

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong, readonly) CLLocation* location;
@property (nonatomic, strong, readonly) Forecast* forecast;

@end
