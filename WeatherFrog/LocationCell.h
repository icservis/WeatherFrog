//
//  LocationCell.h
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Location;

@protocol LocationCellDelegate <NSObject>

- (void)reloadTableViewCell:(UITableViewCell*)cell;

@end

@interface LocationCell : UITableViewCell

@property (nonatomic, strong) Location* location;
@property (nonatomic, weak) id <LocationCellDelegate> delegate;

@end
