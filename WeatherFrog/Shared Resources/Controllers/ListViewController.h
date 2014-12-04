//
//  ListViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 04.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PositionManager.h"

#pragma mark - Cross Platform

#if TARGET_OS_IPHONE
#define LIST_VIEWCONTROLLER_CLASS UITableViewController
#elif TARGET_OS_MAC
#define LIST_VIEWCONTROLLER_CLASS NSViewController
#endif

@interface ListViewController : LIST_VIEWCONTROLLER_CLASS

@end
