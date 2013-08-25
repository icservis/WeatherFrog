//
//  Forecast+Fetch.m
//  WeatherFrog
//
//  Created by Libor Kučera on 24.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Forecast+Fetch.h"
#import "Location+Store.h"

@implementation Forecast (Fetch)


+ (void)fetchWithPlacemark:(CLPlacemark *)placemark success:(void (^)(Forecast *))success failure:(void (^)(NSError *error))failure progress:(void (^)(float))progress
{
    
    NSManagedObjectContext* currentContext = [NSManagedObjectContext contextForCurrentThread];
    Forecast* forecast = [Forecast createInContext:currentContext];
    
    forecast.name = [placemark title];
    forecast.latitude = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
    forecast.longitude = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
    forecast.altitude = @0;
    forecast.placemark = placemark;
    forecast.validTill = [NSDate dateWithTimeIntervalSinceNow:3600];
    forecast.timestamp = [NSDate date];
    
    [Location locationforForecast:forecast];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do a taks in the background
        
        NSInteger cycles = 100;
        for (int i=0;i<cycles;i++) {
            [NSThread sleepForTimeInterval:0.1f];
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
}

- (BOOL)isValidForLocation:(CLLocation*)location accuracy:(CLLocationDistance)accuracy validity:(NSTimeInterval)validity
{
    if (self == nil) {
        return NO;
    }
    if ([self.validTill timeIntervalSinceNow] < 0) {
        return NO;
    }
    if ([self.placemark.location distanceFromLocation:location] > accuracy) {
        return NO;
    }
    if ([self.timestamp timeIntervalSinceNow] > validity) {
        return NO;
    }
    return YES;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"name: %@, timestamp: %@, latitude: %.5f, longitude: %.5f, altitude: %.0f, validTill: %@", self.name, [NSString stringWithDate:self.timestamp], self.placemark.location.coordinate.latitude, self.placemark.location.coordinate.longitude, self.placemark.location.altitude, [NSString stringWithDate:self.validTill]];
}

@end
