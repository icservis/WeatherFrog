//
//  ForecastCell.h
//  WeatherFrog
//
//  Created by Libor Kučera on 14.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Weather;

@protocol ForecastCellDelegate <NSObject>

- (void)reloadTableViewCell:(UITableViewCell*)cell;

@end

@interface ForecastCell : UITableViewCell

@property (nonatomic, strong) Weather* weather;
@property (nonatomic, strong) NSTimeZone* timezone;
@property (nonatomic, weak) id <ForecastCellDelegate> delegate;

@end
