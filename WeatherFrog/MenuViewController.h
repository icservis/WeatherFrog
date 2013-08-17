//
//  MenuViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "SWRevealViewController.h"

@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SettingsViewControllerDelegate>

@end
