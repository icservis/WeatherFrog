//
//  UINavigationController+StausBarStyle.m
//  WeatherFrog
//
//  Created by Libor Kučera on 08/01/14.
//  Copyright (c) 2014 IC Servis. All rights reserved.
//

#import "UINavigationController+StausBarStyle.h"

@implementation UINavigationController (StausBarStyle)

-(UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

@end
