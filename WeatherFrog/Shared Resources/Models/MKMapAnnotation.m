//
//  MKMapAnnotation.m
//  WeatherFrog
//
//  Created by Libor Kučera on 02.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "MKMapAnnotation.h"

@interface MKMapAnnotation ()

@property (nonatomic, readwrite, copy) NSString* title;
@property (nonatomic, readwrite, copy) NSString* subtitle;
@property (nonatomic, readwrite) BOOL hasPlacemark;

@end

@implementation MKMapAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

#pragma mark - Placemark

- (id)initWithPosition:(Position *)position
{
    if (self = [super init]) {
        self.coordinate = position.location.coordinate;
        self.title = [position name];
        self.subtitle = [position address];
        self.hasPlacemark = YES;
    }
    return self;
}

- (void)updateWithPosition:(Position *)position
{
    self.coordinate = position.location.coordinate;
    self.title = [position name];
    self.subtitle = [position address];
    self.hasPlacemark = YES;
}

- (id)initWithPlacemark:(CLPlacemark *)placemark
{
    if (self = [super init]) {
        self.coordinate = placemark.location.coordinate;
        self.title = [placemark title];
        self.subtitle = [placemark subtitle];
        self.hasPlacemark = YES;
    }
    return self;
}

- (void)updateWithPlacemark:(CLPlacemark*)placemark
{
    self.coordinate = placemark.location.coordinate;
    self.title = [placemark title];
    self.subtitle = [placemark subtitle];
    self.hasPlacemark = YES;
}

#pragma mark - Location

- (id)initWithLocation:(CLLocation *)location
{
    if (self = [super init]) {
        self.coordinate = location.coordinate;
        self.title = location.description;
        self.hasPlacemark = NO;
    }
    return self;
}

- (void)updateWithLocation:(CLLocation *)location
{
    self.coordinate = location.coordinate;
    self.title = location.description;
    self.hasPlacemark = NO;
}

@end
