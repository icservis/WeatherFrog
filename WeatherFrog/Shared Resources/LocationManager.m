//
//  LocationManager.m
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

@synthesize currentLocation = _currentLocation;

static LocationManager *SINGLETON = nil;

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
    return [[LocationManager alloc] init];
}

- (id)mutableCopy
{
    return [[LocationManager alloc] init];
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

#pragma mark - Properties

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    _currentLocation = currentLocation;
}

- (CLLocation*)currentLocation
{
    if (_currentLocation == nil) {
        _currentLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(50.f, 14.f) altitude:300.f horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]];
    }
    return _currentLocation;
}


@end
