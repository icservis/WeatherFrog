//
//  MKMapAnnotation.h
//  WeatherFrog
//
//  Created by Libor Kučera on 18.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithPlacemark:(CLPlacemark*)placemark;
- (void)updateWithPlacemark:(CLPlacemark*)placemark;

@end
