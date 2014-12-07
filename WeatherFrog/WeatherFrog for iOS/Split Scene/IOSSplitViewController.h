//
//  SplitViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IOSListViewController, IOSDetailViewController;

static NSString* const KViewControllerWillTrasitionToTraitCollection = @"KViewControllerWillTrasitionToTraitCollection";

@interface IOSSplitViewController : UISplitViewController

@end
