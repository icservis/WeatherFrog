//
//  ForecastViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Forecast;

@protocol ForecastViewControllerDelegate <NSObject>

@end

@interface ForecastViewController : UIViewController

@property (nonatomic, weak) id<ForecastViewControllerDelegate> delegate;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;
@property (nonatomic, strong) Forecast* selectedForecast;

@end
