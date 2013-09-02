//
//  SettingsViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsMultiValueViewController.h"
#import "SettingsSliderViewController.h"

@protocol SettingsViewControllerDelegate <NSObject>

- (void)closeSettingsViewController:(UIViewController*)controller;

@end

@interface SettingsViewController : UITableViewController <SettingsMultiValueViewControllerDelegate, SettingsSliderViewControllerDelegate>

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

@end
