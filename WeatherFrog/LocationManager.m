//
//  LocationManager.m
//  WeatherFrog
//
//  Created by Libor Kučera on 24.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "Location.h"
#import "LocationManager.h"
#import "Forecast+Additions.h"
#import "UserDefaultsManager.h"

@implementation LocationManager

- (Location*)locationWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate altitude:(CLLocationDistance)altitude timezone:(NSTimeZone*)timezone placemark:(CLPlacemark*)placemark
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* currentContext = appDelegate.managedObjectContext;
    
    Location* location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:currentContext];
    
    location.name = name;
    location.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    location.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    location.altitude = [NSNumber numberWithFloat:altitude];
    location.timezone = timezone;
    location.placemark = placemark;
    location.timestamp = [NSDate date];
    location.isMarked = [NSNumber numberWithBool:NO];
    
    DDLogVerbose(@"Location: %@", [location description]);
    
    return location;
}

- (Location*)locationforPlacemark:(CLPlacemark*)placemark withTimezone:(NSTimeZone*)timezone
{
    Location* location = [self locationWithCLPlacemark:placemark];
    
    if (location == nil) {
        
        NSString* name = [placemark title];
        CLLocationCoordinate2D coordinate = placemark.location.coordinate;
        CLLocationDistance altitude = placemark.location.altitude;
        
        location = [self locationWithName:name coordinate:coordinate altitude:altitude timezone:timezone placemark:placemark];
        DDLogInfo(@"new location %@", [location description]);
        
    } else {
        
        location.timestamp = [NSDate date];
        DDLogInfo(@"restored location %@", [location description]);
    }
    
    return location;
}

- (Location*)locationWithCLPlacemark:(CLPlacemark*)placemark
{
    DDLogVerbose(@"nearestLocationWithCLPlacemark");
    Location* location;
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* currentContext = appDelegate.managedObjectContext;
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:currentContext];
    [fetchRequest setEntity:entity];
    NSPredicate* findPredicate = [NSPredicate predicateWithFormat:@"latitude = %@ AND longitude = %@", [NSNumber numberWithDouble:placemark.location.coordinate.latitude], [NSNumber numberWithDouble:placemark.location.coordinate.longitude]];
    [fetchRequest setPredicate:findPredicate];
    NSError* error;
    NSArray* locations = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    if (locations != nil && locations.count > 0) {
        location = [locations firstObject];
    }
    
    return location;
}

- (void)deleteLocation:(Location*)location
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* currentContext = appDelegate.managedObjectContext;
    
    [currentContext deleteObject:location];
}

- (void)deleteObsoleteLocations
{
    DDLogInfo(@"deleteObsoleteLocations");
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* currentContext = appDelegate.managedObjectContext;
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:currentContext];
    [fetchRequest setEntity:entity];
    NSTimeInterval timeinterval = [[[UserDefaultsManager sharedDefaults] forecastValidity] floatValue];
    NSPredicate* deletePredicate = [NSPredicate predicateWithFormat:@"timestamp < %@ AND isMarked = NO", [NSDate dateWithTimeIntervalSinceNow:-timeinterval]];
    [fetchRequest setPredicate:deletePredicate];
    NSError* error;
    NSArray* locations = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    [locations enumerateObjectsUsingBlock:^(Location* obj, NSUInteger idx, BOOL *stop) {
        [currentContext deleteObject:obj];
    }];
}

@end
