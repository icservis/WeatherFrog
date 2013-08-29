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
#import "AstroDictionary.h"
#import "WeatherDictionary.h"

@implementation YrApiService

+ (YrApiService *)sharedService {
    
    static YrApiService* _sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
    
    return _sharedService;
}

- (void)weatherDatatWithLocation:(CLLocation*)location success:(void (^)(NSArray* weatherData))success failure:(void (^)(NSError* error))failure
{
    NSURL* apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/locationforecast/1.8/?lat=%f;lon=%f;msl=%i", kYrAPIUrl, location.coordinate.latitude, location.coordinate.longitude, @(location.altitude).intValue]];
    DDLogVerbose(@"url: %@", [apiURL absoluteString]);
    NSURLRequest* request = [NSURLRequest requestWithURL:apiURL];
    
    AFKissXMLRequestOperation *operation = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do a taks in the background
            
            NSError* error;
            NSArray* nodes = [XMLDocument nodesForXPath:@"/weatherdata/product/time" error:&error];
            
            if (error == nil) {
                
                NSMutableArray* weatherData = [NSMutableArray array];
                
                for (DDXMLElement* node in nodes) {
                    WeatherDictionary* weather = [WeatherDictionary new];
                    weather.timestamp = [NSDate date];
                    [weatherData addObject:weather];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Finish in main queue
                    success(weatherData);
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Finish in main queue
                    DDLogError(@"error: %@", [error description]);
                    failure(error);
                });
            }
        });

        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
        DDLogError(@"error: %@", [error description]);
        failure(error);
    }];
    
    [operation start];
}

- (void)solarDatatWithLocation:(CLLocation *)location success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSURL* apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sunrise/1.0/?lat=%f;lon=%f;from=%@;to=%@", kYrAPIUrl, location.coordinate.latitude, location.coordinate.longitude, [NSString stringWithISODateOnly:[NSDate date]], [NSString stringWithISODateOnly:[NSDate dateWithTimeIntervalSinceNow:kForecastHoursCount*3600]]]];
    DDLogVerbose(@"url: %@", [apiURL absoluteString]);
    NSURLRequest* request = [NSURLRequest requestWithURL:apiURL];
    
    AFKissXMLRequestOperation *operation = [AFKissXMLRequestOperation XMLDocumentRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do a taks in the background
            
            NSError* error;
            NSArray* nodes = [XMLDocument nodesForXPath:@"/astrodata/time" error:&error];
            
            if (error == nil) {
                
                NSMutableArray* astroData = [NSMutableArray array];
                
                for (DDXMLElement* node in nodes) {
                    AstroDictionary* astro = [AstroDictionary new];
                    astro.date = [NSDate date];
                    [astroData addObject:astro];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Finish in main queue
                    success(astroData);
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Finish in main queue
                    DDLogError(@"error: %@", [error description]);
                    failure(error);
                });
            }
        });
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument) {
        DDLogError(@"error: %@", [error description]);
        failure(error);
    }];
    
    [operation start];
    
}

@end
