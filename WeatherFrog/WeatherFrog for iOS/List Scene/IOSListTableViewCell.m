//
//  IOSListTableViewCell.m
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSListTableViewCell.h"

@interface IOSListTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;

@end

@implementation IOSListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setPosition:(Position *)position
{
    _position = position;
    
    self.nameLabel.text = position.name;
    self.addressLabel.text = position.address;
    
}

@end
