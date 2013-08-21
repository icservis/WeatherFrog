//
//  YrApiService.h
//  WeatherFrog
//
//  Created by Libor Kučera on 21.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kYrAPIUrl = @"http://api.yr.no/weatherapi";

@class Forecast;

@interface YrApiService : NSObject <NSXMLParserDelegate>

+ (YrApiService *)sharedService;

- (void)forecastWithLocation:(CLLocation*)location success:(void (^)(Forecast* forecast))success failure:(void (^)())failure;

@end
