//
//  ForecastViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForecastManager.h"
#import "DetailViewController.h"
#import "Banner.h"

@class Forecast;

@protocol ForecastViewControllerDelegate <NSObject>

@end

@interface ForecastViewController : UIViewController <ForecastManagerDelegate, UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate, BannerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<ForecastViewControllerDelegate> delegate;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;
@property (nonatomic, strong) Forecast* selectedForecast;
@property (nonatomic) BOOL useSelectedLocationInsteadCurrenLocation;

- (void)setRevealMode:(BOOL)revealed;
- (void)showSplashScreen;

@end
