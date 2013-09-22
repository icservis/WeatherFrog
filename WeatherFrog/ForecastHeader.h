//
//  ForecastHeader.h
//  WeatherFrog
//
//  Created by Libor Kučera on 22.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Weather;

@interface ForecastHeader : UIView

@property (nonatomic, strong) Weather* weather;
@property (nonatomic, strong) NSTimeZone* timeZone;

+ (CGFloat)forecastHeaderHeight;

@end
