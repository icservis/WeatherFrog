//
//  MapViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 23.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

- (void)mapViewControllerDidClose:(MapViewController*)controller;

@end

@interface MapViewController : NSViewController

@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;

@end
