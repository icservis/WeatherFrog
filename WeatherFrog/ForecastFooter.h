//
//  ForecastFooter.h
//  WeatherFrog
//
//  Created by Libor Kučera on 22.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Astro;
@class Weather;

@interface ForecastFooter : UIView

@property (nonatomic, strong) Astro* astro;
@property (nonatomic, strong) NSTimeZone* timeZone;
@property (nonatomic, strong) NSDate* timestamp;
@property (nonatomic, strong) Weather* weather;

+ (CGFloat)forecastFooterHeight;

@end
