//
//  DetailViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 18.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Weather;

@interface DetailViewController : UIViewController

@property (nonatomic, copy) void (^completionBlock)(BOOL success);
@property (nonatomic, strong) Weather* weather;
@property (nonatomic, strong) NSTimeZone* timezone;

@end
