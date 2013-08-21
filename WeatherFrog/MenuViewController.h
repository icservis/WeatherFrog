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
#import "LocatorViewController.h"
#import "ForecastViewController.h"


@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SettingsViewControllerDelegate, LocatorViewControllerDelegate, ForecastViewControllerDelegate>

@property (nonatomic, strong) LocatorViewController* locatorViewController;
@property (nonatomic, strong) ForecastViewController* forecastViewController;

@property (nonatomic, strong) CLPlacemark* currentPlacemark;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;

@end
