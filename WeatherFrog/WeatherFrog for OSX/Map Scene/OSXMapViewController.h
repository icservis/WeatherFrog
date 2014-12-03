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

- (void)mapViewController:(OSXMapViewController *)controller didSelectPosition:(Position *)position bookmark:(BOOL)shouldBookmark;

@end

@interface OSXMapViewController : NSViewController

@property (nonatomic, weak) id <OSXMapViewControllerDelegate> delegate;
@property (nonatomic, copy) void (^closeBlock)(void);
@property (nonatomic, strong) Position* selectedPosition;

@end
