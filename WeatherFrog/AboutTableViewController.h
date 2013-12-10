//
//  AboutTableViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 10.12.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AboutTableViewControllerDelegate <NSObject>

- (void)closeAboutTableViewController:(UITableViewController*)controller;

@end

@interface AboutTableViewController : UITableViewController <UITableViewDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) id <AboutTableViewControllerDelegate> delegate;

@end
