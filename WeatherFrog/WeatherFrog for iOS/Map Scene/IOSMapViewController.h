//
//  MapViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IOSMapViewController;

@protocol IOSMapViewControllerDelegate <NSObject>

- (void)mapViewControllerDidSelectLocation:(CLLocation*)location storeLocation:(BOOL)shouldStoreLocation;

@end

@interface IOSMapViewController : UIViewController

@property (nonatomic, weak) id <IOSMapViewControllerDelegate> delegate;
@property (nonatomic, copy) void (^closeBlock)(void);

@end
