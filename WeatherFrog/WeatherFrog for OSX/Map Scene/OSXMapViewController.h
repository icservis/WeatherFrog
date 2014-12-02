//
//  MapViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 23.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSXMapViewController;

@protocol OSXMapViewControllerDelegate <NSObject>

- (void)mapViewControllerDidSelectLocation:(CLLocation*)location storeLocation:(BOOL)shouldStoreLocation;

@end

@interface OSXMapViewController : NSViewController

@property (nonatomic, weak) id <OSXMapViewControllerDelegate> delegate;
@property (nonatomic, copy) void (^closeBlock)(void);

@end
