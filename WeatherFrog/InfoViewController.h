//
//  InfoViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 13.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewControllerDelegate <NSObject>

- (void)closeInfoViewController:(UIViewController*)controller;

@end

@interface InfoViewController : UIViewController

@property (nonatomic, weak) id <InfoViewControllerDelegate> delegate;

@end
