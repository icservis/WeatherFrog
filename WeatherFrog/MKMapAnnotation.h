//
//  MKMapAnnotation.h
//  WeatherFrog
//
//  Created by Libor Kučera on 18.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly, copy) NSString* subtitle;

- (id)initWithPlacemark:(CLPlacemark*)placemark;
- (void)updateWithPlacemark:(CLPlacemark*)placemark;
- (id)initWithLocation:(CLLocation *)location;
- (void)updateWithLocation:(CLLocation *)location;

@end
