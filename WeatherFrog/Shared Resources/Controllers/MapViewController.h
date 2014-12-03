//
//  MapViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PositionManager.h"

#pragma mark - Cross Platform

#if TARGET_OS_IPHONE
    #define VIEWCONTROLLER_CLASS UIViewController
    #define BUTTON_CLASS UIButton
#elif TARGET_OS_MAC
    #define VIEWCONTROLLER_CLASS NSViewController
    #define BUTTON_CLASS NSButton
#endif


@interface MapViewController : VIEWCONTROLLER_CLASS

@end
