//
//  IOSListTableViewCell.h
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const ListCellIdentifier = @"ListCell";

@interface IOSListTableViewCell : UITableViewCell

@property (nonatomic, weak) Position* position;

@end
