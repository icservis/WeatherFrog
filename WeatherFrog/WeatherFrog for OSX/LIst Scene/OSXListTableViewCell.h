//
//  OSXListTableViewCell.h
//  WeatherFrog
//
//  Created by Libor Kučera on 04.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static NSString* const ListCellIdentifier = @"ListCell";

@interface OSXListTableViewCell : NSTableCellView

@property (nonatomic, weak) Position* position;

@end
