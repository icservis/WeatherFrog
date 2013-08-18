//
//  MKMapAnnotation.m
//  WeatherFrog
//
//  Created by Libor Kučera on 18.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "MKMapAnnotation.h"


@implementation MKMapAnnotation

- (id)initWithPlacemark:(CLPlacemark *)placemark
{
    if (self = [super init]) {
        self.coordinate = placemark.location.coordinate;
        self.title = placemark.name;
        self.subtitle = placemark.country;
    }
    return self;
}

- (void)updateWithPlacemark:(CLPlacemark*)placemark
{
    self.coordinate = placemark.location.coordinate;
    self.title = placemark.name;
    self.subtitle = placemark.country;
}

@end
