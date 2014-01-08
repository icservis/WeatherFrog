//
//  AboutTableViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 10.12.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutTableViewController : UITableViewController

@property (nonatomic, copy) void (^completionBlock) (BOOL success);

@end
