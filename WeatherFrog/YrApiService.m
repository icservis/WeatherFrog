//
//  YrApiService.m
//  WeatherFrog
//
//  Created by Libor Kučera on 21.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "YrApiService.h"
#import "AFNetworking.h"
#import "AFKissXMLRequestOperation.h"
#import "Forecast.h"

@implementation YrApiService

+ (YrApiService *)sharedService {
    
    static YrApiService* _sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
    
    return _sharedService;
}

- (void)forecastWithLocation:(CLLocation*)location success:(void (^)(Forecast* forecast))success failure:(void (^)())failure
{
    NSURL* apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/locationforecast/1.8/?lat=%f;lon=%f;msl=%i", kYrAPIUrl, location.coordinate.latitude, location.coordinate.longitude, @(location.altitude).intValue]];
    DDLogVerbose(@"url: %@", [apiURL absoluteString]);
    NSURLRequest* request = [NSURLRequest requestWithURL:apiURL];
    
    AFKissXMLRequestOperation *operation = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument) {
        
        NSError* error;
        NSArray* nodes = [XMLDocument nodesForXPath:@"/weatherdata/product/time" error:&error];
        
        if (error == nil) {
            
            for (DDXMLElement* node in nodes) {
                DDLogVerbose(@"node: %@", [node description]);
            }
            
            success(nil);
        } else {
            DDLogError(@"error: %@", [error description]);
            failure();
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
        DDLogError(@"Failure! error:%@", [error description]);
        failure();
    }];
    
    [operation start];
}

@end
