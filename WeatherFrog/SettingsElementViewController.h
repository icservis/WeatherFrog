//
//  SettingsElementViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 01.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsElementViewControllerDelegate <NSObject>

- (void)closeSettingsElementViewController:(UITableViewController*)controller;
- (void)settingsViewController:(UITableViewController*)controller didUpdatedElement:(NSString*)element value:(id)value;

@end

@interface SettingsElementViewController : UITableViewController

@property (nonatomic, weak) id <SettingsElementViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSArray* titles;
@property (nonatomic, strong) NSArray* values;
@property (nonatomic, strong) id value;

@end
