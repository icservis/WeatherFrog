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

@property (nonatomic, strong, readwrite) CLLocation* currentLocation;
@property (nonatomic, strong, readwrite) CLPlacemark* currentPlacemark;
@property (nonatomic, strong, readwrite) Position* currentPosition;

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLGeocoder* geocoder;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSError* error;

@end

@implementation PositionManager

@synthesize currentLocation = _currentLocation;

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

#pragma mark - Current Location

- (CLLocationManager*)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)startMonitoringCurrentLocation
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
        }
    }
    
    #pragma clang diagnostic pop
    
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoringCurrentLocation
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] > 0) {
        CLLocation* location = [locations firstObject];
        DDLogVerbose(@"location: %@", location);
        self.currentLocation = location;
        
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil) {
                CLPlacemark* placemark = [placemarks firstObject];
                DDLogVerbose(@"placemark: %@", placemark);
                self.currentPlacemark = placemark;
                self.currentPosition = [self positionForPlacemark:placemark];
            } else {
                self.error = error;
            }
        }];
    }
}

#pragma mark - Geocoder

- (CLGeocoder*)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}


#pragma mark - Position


- (Position*)positionForPlacemark:(CLPlacemark*)placemark
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Position class]) inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(@selector(timestamp)) ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
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
        position.timestamp = placemark.location.timestamp;
        position.name = [placemark title];
        position.address = [placemark subTitle];
        position.updatedAt = [NSDate date];
    }
        
    return position;
}

@end
