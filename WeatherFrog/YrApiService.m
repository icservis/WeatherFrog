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

@interface YrApiService ()

@property (nonatomic, strong) NSDateFormatter* gmtDateFormatter;
@property (nonatomic, strong) NSDateFormatter* gmtDateTimeFormatter;

@end

@implementation YrApiService

@synthesize gmtDateFormatter = _gmtDateFormatter;
@synthesize gmtDateTimeFormatter = _gmtDateTimeFormatter;

#pragma mark - intitialization

+ (YrApiService *)sharedService {
    
    static YrApiService* _sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
    
    return _sharedService;
}

#pragma mark - setters and getters

-(NSDateFormatter*)gmtDateFormatter
{
    if (_gmtDateFormatter == nil) {
        _gmtDateFormatter = [[NSDateFormatter alloc] init];
        [_gmtDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [_gmtDateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _gmtDateFormatter;
}

-(NSDateFormatter*)gmtDateTimeFormatter
{
    if (_gmtDateTimeFormatter == nil) {
        _gmtDateTimeFormatter = [[NSDateFormatter alloc] init];
        [_gmtDateTimeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [_gmtDateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return _gmtDateTimeFormatter;
}

#pragma mark - fetching data

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
                    
                    NSString* date = [[node attributeForName:@"date"] stringValue];
                    astro.date = [self.gmtDateFormatter dateFromString:date];
                    
                    for (DDXMLElement *location in [node elementsForName:@"location"]) {
                        // locations loop
                        
                        // SUN
                        for (DDXMLElement* sun in [location elementsForName:@"sun"]) {
                            
                            NSString* sunRise = [[sun attributeForName:@"rise"] stringValue];
                            astro.sunRise = [self.gmtDateTimeFormatter dateFromString:sunRise];
                            
                            NSString* sunSet = [[sun attributeForName:@"set"] stringValue];
                            astro.sunSet = [self.gmtDateTimeFormatter dateFromString:sunSet];
                            
                            BOOL neverRise = [[[sun attributeForName:@"never_rise"] stringValue] boolValue];
                            astro.sunNeverRise = [NSNumber numberWithBool:neverRise];
                            
                            BOOL neverSet = [[[sun attributeForName:@"never_set"] stringValue] boolValue];
                            astro.sunNeverSet = [NSNumber numberWithBool:neverSet];
                            
                            float dayLength = [[[sun attributeForName:@"daylength"] stringValue] boolValue];
                            astro.dayLength = [NSNumber numberWithFloat:dayLength];
                            
                            for (DDXMLElement* noon in [sun elementsForName:@"noon"]) {
                                float noonAltitude = [[[noon attributeForName:@"altitude"] stringValue] floatValue];
                                astro.noonAltitude = [NSNumber numberWithFloat:noonAltitude];
                                break;
                            }
                            
                            break;
                        }
                        
                        // MOON
                        for (DDXMLElement* moon in [location elementsForName:@"moon"]) {
                            
                            NSString* moonRise = [[moon attributeForName:@"rise"] stringValue];
                            astro.moonRise = [self.gmtDateTimeFormatter dateFromString:moonRise];
                            
                            NSString* moonSet = [[moon attributeForName:@"set"] stringValue];
                            astro.moonSet = [self.gmtDateTimeFormatter dateFromString:moonSet];
                            
                            NSString* moonPhase = [[moon attributeForName:@"phase"] stringValue];
                            astro.moonPhase = moonPhase;
                            
                            break;
                        }
                    }
                    DDLogVerbose(@"astro: %@", [astro description]);
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
