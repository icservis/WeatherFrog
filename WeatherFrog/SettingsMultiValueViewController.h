//
//  SettingsElementViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 01.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsMultiValueViewControllerDelegate <NSObject>

- (void)closeSettingsMultiValueViewController:(UITableViewController*)controller;
- (void)settingsMultiValueViewController:(UITableViewController*)controller didUpdatedMultiValue:(NSString*)element value:(id)value;

@end

@interface SettingsMultiValueViewController : UITableViewController

@property (nonatomic, weak) id <SettingsMultiValueViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSArray* titles;
@property (nonatomic, strong) NSArray* values;
@property (nonatomic, strong) id value;

@end
