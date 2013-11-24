//
//  MenuViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "InfoViewController.h"
#import "SWRevealViewController.h"
#import "LocatorViewController.h"
#import "ForecastViewController.h"
#import "LocationCell.h"


@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SettingsViewControllerDelegate, LocatorViewControllerDelegate, ForecastViewControllerDelegate, NSFetchedResultsControllerDelegate, LocationCellDelegate, InfoViewControllerDelegate, SWRevealViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;

- (void)updatePlacemark:(CLPlacemark*)placemark;

@end
