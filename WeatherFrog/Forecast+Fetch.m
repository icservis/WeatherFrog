//
//  Forecast+Fetch.m
//  WeatherFrog
//
//  Created by Libor Kučera on 24.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "Forecast+Fetch.h"
#import "Location+Store.h"
#import "GoogleApiService.h"

@implementation Forecast (Fetch)


+ (void)fetchWithPlacemark:(CLPlacemark *)placemark forceUpdate:(BOOL)force success:(void (^)(Forecast *))success failure:(void (^)(NSError *error))failure progress:(void (^)(float))progress
{
    
    NSManagedObjectContext* currentContext = [NSManagedObjectContext contextForCurrentThread];
    
    Forecast* forecast;
    
    if (force == NO) {
        
        NSPredicate* findPredicate = [NSPredicate predicateWithFormat:@"validTill > %@", [NSDate date]];
        NSArray* forecasts = [Forecast findAllWithPredicate:findPredicate inContext:currentContext];
        
        if (forecasts != nil) {
            
            CLLocation* placemarkLocation = [[CLLocation alloc] initWithCoordinate:placemark.location.coordinate altitude:placemark.location.altitude horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:placemark.location.timestamp];
            
            NSMutableArray* availableForecasts = [NSMutableArray array];
            for (Forecast* forecast in forecasts) {
                CLLocation* forecastLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake([forecast.latitude doubleValue], [forecast.longitude doubleValue]) altitude:[forecast.altitude floatValue] horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:forecast.timestamp];
                
                if ([forecastLocation distanceFromLocation:placemarkLocation] <= kForecastAccuracy) {
                    [availableForecasts addObject:forecast];
                }
            }
            
            if (availableForecasts.count > 0) {
                
                NSArray* sortedForecasts;
                sortedForecasts = [availableForecasts sortedArrayUsingComparator:^NSComparisonResult(Forecast* obj1, Forecast* obj2) {
                    NSDate* firstTimestamp = obj1.timestamp;
                    NSDate* secondTimestamp = obj2.timestamp;
                    
                    return  [firstTimestamp compare:secondTimestamp];
                }];
                
                forecast = sortedForecasts[0];
                
            } else {
                DDLogVerbose(@"nearestForecast not valid");
            }
        }
    }
    
    if (forecast != nil) {
        
        success(forecast);
        
    } else {
        
        forecast = [Forecast createInContext:currentContext];
        forecast.name = [placemark title];
        forecast.latitude = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
        forecast.longitude = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
        forecast.altitude = @0;
        forecast.placemark = placemark;
        forecast.validTill = [NSDate dateWithTimeIntervalSinceNow:86400];
        forecast.timestamp = [NSDate date];
        
        if (force == NO) {
            [Location locationforForecast:forecast];
        }
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([appDelegate isHostActive]) {
            
            
            
            
            
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do a taks in the background
                
                NSInteger cycles = 100;
                for (int i=0;i<cycles;i++) {
                    [NSThread sleepForTimeInterval:0.01f];
                    float pgs = (float)i/(float)cycles;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Finish in main queue
                        progress(pgs);
                    });
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Finish in main queue
                    success(forecast);
                });
            });
            
        } else {
            NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"Network connection not available", nil), @"localizedDescription", nil];
            NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:dict];
            failure(error);
        }
    }
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"name: %@, timestamp: %@, latitude: %.5f, longitude: %.5f, altitude: %.0f, validTill: %@", self.name, [NSString stringWithDate:self.timestamp], self.placemark.location.coordinate.latitude, self.placemark.location.coordinate.longitude, self.placemark.location.altitude, [NSString stringWithDate:self.validTill]];
}

@end
