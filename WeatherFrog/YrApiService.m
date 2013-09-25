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
#import "Astro.h"
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
                    
                    WeatherDictionary* weather;
                    NSString* timestampFrom = [[node attributeForName:@"from"] stringValue];
                    NSString* timestampTo = [[node attributeForName:@"to"] stringValue];
                    
                    if ([timestampFrom isEqualToString:timestampTo]) {
                        
                        weather = [WeatherDictionary new];
                        weather.timestamp = [self.gmtDateTimeFormatter dateFromString:timestampTo];
                        
                        for (DDXMLElement* location in [node elementsForName:@"location"]) {
                            
                            for (DDXMLElement* temperature in [location elementsForName:@"temperature"]) {
                                float temperatureCelsius = [[[temperature attributeForName:@"value"] stringValue] floatValue];
                                weather.temperature = [NSNumber numberWithFloat:temperatureCelsius];
                                break;
                            }
                            
                            for (DDXMLElement* windDirection in [location elementsForName:@"windDirection"]) {
                                float windDirectionDegrees = [[[windDirection attributeForName:@"deg"] stringValue] floatValue];
                                weather.windDirection = [NSNumber numberWithFloat:windDirectionDegrees];
                                break;
                            }
                            
                            for (DDXMLElement* windSpeed in [location elementsForName:@"windSpeed"]) {
                                float windSpeedMps = [[[windSpeed attributeForName:@"mps"] stringValue] floatValue];
                                weather.windSpeed = [NSNumber numberWithFloat:windSpeedMps];
                                NSInteger windSpeedBeaufort = [[[windSpeed attributeForName:@"beaufort"] stringValue] integerValue];
                                weather.windScale = [NSNumber numberWithInteger:windSpeedBeaufort];
                                break;
                            }
                            
                            for (DDXMLElement* humidity in [location elementsForName:@"humidity"]) {
                                float humidityPercent = [[[humidity attributeForName:@"value"] stringValue] floatValue];
                                weather.humidity = [NSNumber numberWithFloat:humidityPercent];
                                break;
                            }
                            
                            for (DDXMLElement* pressure in [location elementsForName:@"pressure"]) {
                                float pressureHpa = [[[pressure attributeForName:@"value"] stringValue] floatValue];
                                weather.pressure = [NSNumber numberWithFloat:pressureHpa];
                                break;
                            }
                            
                            for (DDXMLElement* cloudiness in [location elementsForName:@"cloudiness"]) {
                                float cloudinessPercent = [[[cloudiness attributeForName:@"percent"] stringValue] floatValue];
                                weather.cloudiness = [NSNumber numberWithFloat:cloudinessPercent];
                                break;
                            }
                            
                            for (DDXMLElement* fog in [location elementsForName:@"fog"]) {
                                float fogPercent = [[[fog attributeForName:@"percent"] stringValue] floatValue];
                                weather.fog = [NSNumber numberWithFloat:fogPercent];
                                break;
                            }
                            
                            for (DDXMLElement* lowClouds in [location elementsForName:@"lowClouds"]) {
                                float lowCloudsPercent = [[[lowClouds attributeForName:@"percent"] stringValue] floatValue];
                                weather.lowClouds = [NSNumber numberWithFloat:lowCloudsPercent];
                                break;
                            }
                            
                            for (DDXMLElement* mediumClouds in [location elementsForName:@"mediumClouds"]) {
                                float mediumCloudsPercent = [[[mediumClouds attributeForName:@"percent"] stringValue] floatValue];
                                weather.mediumClouds = [NSNumber numberWithFloat:mediumCloudsPercent];
                                break;
                            }
                            
                            for (DDXMLElement* highClouds in [location elementsForName:@"highClouds"]) {
                                float highCloudsPercent = [[[highClouds attributeForName:@"percent"] stringValue] floatValue];
                                weather.highClouds = [NSNumber numberWithFloat:highCloudsPercent];
                                break;
                            }
                        
                            break;
                        }
                        
                        weather.created = [NSDate date];
                        [weatherData addObject:weather];
                        
                    } else {
                        
                        weather = [weatherData lastObject];
                        
                        NSDate* timestampFromDate = [self.gmtDateTimeFormatter dateFromString:timestampFrom];
                        NSDate* timestampToDate = [self.gmtDateTimeFormatter dateFromString:timestampTo];
                        
                        NSTimeInterval timestampDifference = [timestampToDate timeIntervalSinceDate:timestampFromDate];
                        
                        for (DDXMLElement* location in [node elementsForName:@"location"]) {
                            
                            for (DDXMLElement* precipitation in [location elementsForName:@"precipitation"]) {
                                
                                
                                float precipitationMm = [[[precipitation attributeForName:@"value"] stringValue] floatValue];
                                float precipitationMinMm = [[[precipitation attributeForName:@"minvalue"] stringValue] floatValue];
                                float precipitationMaxMm = [[[precipitation attributeForName:@"maxvalue"] stringValue] floatValue];
                                
                                if (timestampDifference/3600 == 1) {
                                    weather.precipitation1h = [NSNumber numberWithFloat:precipitationMm];
                                    weather.precipitationMin1h = [NSNumber numberWithFloat:precipitationMinMm];
                                    weather.precipitationMax1h = [NSNumber numberWithFloat:precipitationMaxMm];
                                }
                                
                                if (timestampDifference/3600 == 2) {
                                    weather.precipitation2h = [NSNumber numberWithFloat:precipitationMm];
                                    weather.precipitationMin2h = [NSNumber numberWithFloat:precipitationMinMm];
                                    weather.precipitationMax2h = [NSNumber numberWithFloat:precipitationMaxMm];
                                }
                                
                                if (timestampDifference/3600 == 3) {
                                    weather.precipitation3h = [NSNumber numberWithFloat:precipitationMm];
                                    weather.precipitationMin3h = [NSNumber numberWithFloat:precipitationMinMm];
                                    weather.precipitationMax3h = [NSNumber numberWithFloat:precipitationMaxMm];
                                }
                                
                                if (timestampDifference/3600 == 6) {
                                    weather.precipitation6h = [NSNumber numberWithFloat:precipitationMm];
                                    weather.precipitationMin6h = [NSNumber numberWithFloat:precipitationMinMm];
                                    weather.precipitationMax6h = [NSNumber numberWithFloat:precipitationMaxMm];
                                }
                                
                                break;
                            }
                            
                            for (DDXMLElement* symbol in [location elementsForName:@"symbol"]) {
                                
                                NSInteger symbolInteger = [[[symbol attributeForName:@"number"] stringValue] integerValue];
                                
                                if (timestampDifference/3600 == 1) {
                                    weather.symbol1h = [NSNumber numberWithInteger:symbolInteger];
                                }
                                
                                if (timestampDifference/3600 == 2) {
                                    weather.symbol2h = [NSNumber numberWithInteger:symbolInteger];;
                                }
                                
                                if (timestampDifference/3600 == 3) {
                                    weather.symbol3h = [NSNumber numberWithInteger:symbolInteger];
                                }
                                
                                if (timestampDifference/3600 == 6) {
                                    weather.symbol6h = [NSNumber numberWithInteger:symbolInteger];
                                }
                                
                                break;
                            }
                            
                        }
                    }
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

- (void)astroDatatWithLocation:(CLLocation *)location success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSURL* apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sunrise/1.0/?lat=%f;lon=%f;from=%@;to=%@", kYrAPIUrl, location.coordinate.latitude, location.coordinate.longitude, [NSString stringWithISODateOnly:[NSDate date]], [NSString stringWithISODateOnly:[NSDate dateWithTimeIntervalSinceNow:kAstroFeedHoursCount*3600]]]];
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
