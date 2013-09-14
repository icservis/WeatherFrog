//
//  ForecastCell.h
//  WeatherFrog
//
//  Created by Libor Kučera on 14.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Weather;

@interface ForecastCell : UITableViewCell

@property (nonatomic, strong) Weather* weather;
@property (nonatomic, strong) NSTimeZone* timezone;

@end
