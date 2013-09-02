//
//  SettingsSliderViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 02.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsSliderViewControllerDelegate <NSObject>

- (void)closeSettingsSliderViewController:(UIViewController*)controller;
- (void)settingsSliderController:(UIViewController*)controller didUpdatedSlider:(NSString*)element value:(id)value;

@end

@interface SettingsSliderViewController : UIViewController

@property (nonatomic, weak) id <SettingsSliderViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSNumber* minValue;
@property (nonatomic, strong) NSNumber* maxValue;
@property (nonatomic, strong) id value;

@end
