//
//  YrApiService.h
//  WeatherFrog
//
//  Created by Libor Kučera on 21.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kYrAPIUrl = @"http://api.yr.no/weatherapi";

@interface YrApiService : NSObject <NSXMLParserDelegate>

+ (YrApiService *)sharedService;

- (void)weatherDatatWithLocation:(CLLocation*)location success:(void (^)(NSArray* weatherData))success failure:(void (^)(NSError* error))failure;

- (void)solarDatatWithLocation:(CLLocation*)location success:(void (^)(NSArray* solarData))success failure:(void (^)(NSError* error))failure;

@end
