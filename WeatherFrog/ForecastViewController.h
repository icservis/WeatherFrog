//
//  ForecastViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForecastManager.h"

@class Forecast;

@protocol ForecastViewControllerDelegate <NSObject>

@end

@interface ForecastViewController : UIViewController <ForecastManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<ForecastViewControllerDelegate> delegate;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;
@property (nonatomic, strong) Forecast* selectedForecast;
@property (nonatomic) BOOL useSelectedLocationInsteadCurrenLocation;

@end
