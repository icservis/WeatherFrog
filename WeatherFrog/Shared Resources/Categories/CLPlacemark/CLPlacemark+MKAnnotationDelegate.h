//
//  CLPlacemark+MKAnnotationDelegate.h
//  WeatherFrog
//
//  Created by Libor Kučera on 24.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLPlacemark (MKAnnotationDelegate)

- (NSString*)title;
- (NSString*)subTitle;

@end
