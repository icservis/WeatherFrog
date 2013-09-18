//
//  DetailViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 18.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Weather;

@protocol DetailViewControllerDelegate <NSObject>

- (void)closeDetailViewController:(UIViewController*)controller;

@end

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <DetailViewControllerDelegate> delegate;
@property (nonatomic, strong) Weather* weather;
@property (nonatomic, strong) NSTimeZone* timezone;

@end
