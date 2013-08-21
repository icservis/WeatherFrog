//
//  ElevatorApiService.h
//  WeatherFrog
//
//  Created by Libor Kučera on 19.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kGoogleAPIUrl = @"https://maps.googleapis.com/maps/api";

@interface GoogleApiService : NSObject

+ (GoogleApiService *)sharedService;

- (void)elevationWithCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(float elevation))success failure:(void (^)())failure;
- (void)timezoneWithCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(NSString* timezoneName))success failure:(void (^)())failure;

@end
