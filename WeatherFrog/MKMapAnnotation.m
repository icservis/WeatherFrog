//
//  MKMapAnnotation.m
//  WeatherFrog
//
//  Created by Libor Kučera on 18.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
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

- (id)initWithPlacemark:(CLPlacemark *)placemark
{
    if (self = [super init]) {
        self.coordinate = placemark.location.coordinate;
        self.title = [placemark title];
        self.subtitle = [placemark subTitle];
        self.hasPlacemark = YES;
    }
    return self;
}

- (void)updateWithPlacemark:(CLPlacemark*)placemark
{
    self.coordinate = placemark.location.coordinate;
    self.title = [placemark title];
    self.subtitle = [placemark subTitle];
    self.hasPlacemark = YES;
}

#pragma mark - Location

- (id)initWithLocation:(CLLocation *)location
{
    if (self = [super init]) {
        self.coordinate = location.coordinate;
        self.title = NSLocalizedString(@"Placemark", nil);
        self.subtitle = [NSString stringWithFormat:@"@ %.5f, %.5f", location.coordinate.latitude, location.coordinate.longitude];
        self.hasPlacemark = NO;
    }
    return self;
}

- (void)updateWithLocation:(CLLocation *)location
{
    self.coordinate = location.coordinate;
    self.title = NSLocalizedString(@"Placemark", nil);
    self.subtitle = [NSString stringWithFormat:@"@ %.5f, %.5f", location.coordinate.latitude, location.coordinate.longitude];
    self.hasPlacemark = NO;
}

@end
