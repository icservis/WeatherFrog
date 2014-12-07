//
//  DetailViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#pragma mark - Cross Platform

#import "MapViewController.h"

#if TARGET_OS_IPHONE
#define DETAIL_VIEWCONTROLLER_CLASS UIViewController
#elif TARGET_OS_MAC
#define DETAIL_VIEWCONTROLLER_CLASS NSTabViewController
#endif

static NSString* const kSelectedPositionObserverKeyName = @"selectedPosition";

@interface DetailViewController : DETAIL_VIEWCONTROLLER_CLASS <MapViewControllerDelegate>

@property (nonatomic, strong) Position* selectedPosition;

- (void)forecastForPosition:(Position*)position withCompletionBlock:(void(^)(BOOL updated, NSError* error))completionBlock;
- (void)activityIndicatorIncrementCount;
- (void)activityIndicatorDecrementCount;

@end
