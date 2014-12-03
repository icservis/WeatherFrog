//
//  LocationManager.m
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "PositionManager.h"
#import "DataService.h"

@interface PositionManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSError* error;

@end

@implementation PositionManager


static PositionManager *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

- (id)copy
{
    return [[PositionManager alloc] init];
}

- (id)mutableCopy
{
    return [[PositionManager alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    return self;
}

#pragma mark - MOC

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = [DataService sharedInstance].managedObjectContext;
    }
    return _managedObjectContext;
}

#pragma mark - Position


- (Position*)positionForPlacemark:(CLPlacemark*)placemark timezoneId:(NSString*)timezoneId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Position class]) inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    /*
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(@selector(timestamp)) ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
     */
    
    NSError *error = nil;
    NSArray *positions = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Position* position;
    if (positions != nil) {
        
        NSArray* sortedPositions = [positions sortedArrayUsingComparator:^NSComparisonResult(Position* obj1, Position* obj2) {
            CLLocationDistance  distanceObj1 = [obj1.location distanceFromLocation:placemark.location];
            CLLocationDistance  distanceObj2 = [obj2.location distanceFromLocation:placemark.location];
            
            if (distanceObj1 < distanceObj2) {
                return NSOrderedAscending;
            } else if (distanceObj1 > distanceObj2) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        Position* nearestPosition = [sortedPositions firstObject];
        CLLocationDistance  distance = [nearestPosition.location distanceFromLocation:placemark.location];
        
        if (distance <= kCLLocationAccuracyHundredMeters) {
            position = nearestPosition;
        }
    }
    
    if (position == nil) {
        position = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Position class]) inManagedObjectContext:self.managedObjectContext];
        position.createdAt = [NSDate date];
        position.latitude = @(placemark.location.coordinate.latitude);
        position.longitude = @(placemark.location.coordinate.longitude);
        position.altitude = @(placemark.location.altitude);
        position.horizontalAccuracy = @(placemark.location.horizontalAccuracy);
        position.verticalAccuracy = @(placemark.location.verticalAccuracy);
        position.timestamp = placemark.location.timestamp;
        position.name = [placemark title];
        position.address = [placemark subTitle];
        position.timezoneId = timezoneId;
        position.updatedAt = [NSDate date];
    }
        
    return position;
}

@end
