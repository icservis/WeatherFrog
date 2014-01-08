//
//  InfoViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 13.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

@property (nonatomic, copy) void (^compleletonBlock) (BOOL success);

@end
