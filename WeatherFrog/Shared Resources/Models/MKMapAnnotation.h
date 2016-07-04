//
//  MKMapAnnotation.h
//  WeatherFrog
//
//  Created by Libor Kučera on 02.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Position, Forecast;

@interface MKMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly, copy) NSString* subtitle;
@property (nonatomic, readonly) BOOL hasPlacemark;

- (id)initWithPosition:(Position *)position;
- (void)updateWithPosition:(Position *)position;
- (id)initWithPlacemark:(CLPlacemark*)placemark;
- (void)updateWithPlacemark:(CLPlacemark*)placemark;
- (id)initWithLocation:(CLLocation *)location;
- (void)updateWithLocation:(CLLocation *)location;

@end
