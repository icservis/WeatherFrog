//
//  AppDelegate.h
//  WeatherFrog for iOS
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IOSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) CLLocation* currentLocation;
@property (nonatomic, strong, readonly) CLPlacemark* currentPlacemark;
@property (nonatomic, strong, readonly) Position* currentPosition;

@end

