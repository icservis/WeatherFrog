//
//  ElevatorApiService.m
//  WeatherFrog
//
//  Created by Libor Kučera on 19.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "GoogleApiService.h"
#import "AFNetworking.h"

@implementation GoogleApiService

+ (GoogleApiService *)sharedService {
    
    static GoogleApiService* _sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
    
    return _sharedService;
}

- (void)elevationWithCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(float elevation))success failure:(void (^)())failure
{
    NSURL* apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/elevation/json?locations=%f,%f&timestamp=%f&sensor=false", kGoogleAPIUrl, coordinate.latitude, coordinate.longitude, [[NSDate date] timeIntervalSince1970]]];
    DDLogVerbose(@"url: %@", [apiURL absoluteString]);
    NSURLRequest* request = [NSURLRequest requestWithURL:apiURL];
    
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSArray* results = [JSON valueForKeyPath:@"results"];
        NSDictionary* result = results[0];
        float elevationValue = [[result objectForKey:@"elevation"] floatValue];
        success(elevationValue);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        DDLogError(@"Failure! error:%@", [error description]);
        failure();
    }];
    [operation start];
}

- (void)timezoneWithCoordinate:(CLLocationCoordinate2D)coordinate success:(void (^)(NSString* timezoneName))success failure:(void (^)())failure
{
    NSURL* apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timezone/json?location=%f,%f&timestamp=%f&sensor=false", kGoogleAPIUrl, coordinate.latitude, coordinate.longitude, [[NSDate date] timeIntervalSince1970]]];
    DDLogVerbose(@"url: %@", [apiURL absoluteString]);
    NSURLRequest* request = [NSURLRequest requestWithURL:apiURL];
    
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString* timezoneId = [JSON valueForKeyPath:@"timeZoneId"];
        success(timezoneId);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        DDLogError(@"Failure! error:%@", [error description]);
        failure();
    }];
    [operation start];
}

@end
