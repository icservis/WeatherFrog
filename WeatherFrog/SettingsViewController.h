//
//  SettingsViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (nonatomic, copy) void (^completionBlock) (BOOL success);

@end
