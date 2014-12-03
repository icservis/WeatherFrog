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

- (void)mapViewController:(IOSMapViewController*)controller didSelectPosition:(Position*)position bookmark:(BOOL)shouldBookmark;

@end

@interface IOSMapViewController : UIViewController

@property (nonatomic, weak) id <IOSMapViewControllerDelegate> delegate;
@property (nonatomic, copy) void (^closeBlock)(void);
@property (nonatomic, strong) Position* selectedPosition;

@end
