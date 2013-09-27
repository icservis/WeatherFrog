//
//  LocationCell.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "LocationCell.h"
#import "Location.h"

@interface LocationCell()

@property (nonatomic, weak) IBOutlet UILabel* title;
@property (nonatomic, weak) IBOutlet UILabel* subTitle;
@property (nonatomic, weak) IBOutlet UIButton* markButton;

- (IBAction)markButtonTapped:(id)sender;

@end

@implementation LocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLocation:(Location *)location
{
    _location = location;
    
    self.title.text = [location.placemark title];
    self.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.subTitle.text = [location.placemark subTitle];
    self.subTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.accessoryType = UITableViewCellAccessoryNone;
    
    if ([location.isMarked isEqualToNumber:@YES]) {
        [_markButton setImage:[UIImage imageNamed:@"minus-30"] forState:UIControlStateNormal];
    } else {
        [_markButton setImage:[UIImage imageNamed:@"plus-30"] forState:UIControlStateNormal];
    }
}

- (IBAction)markButtonTapped:(id)sender
{
    if ([self.location.isMarked boolValue]) {
        self.location.isMarked = [NSNumber numberWithBool:NO];
    } else {
        self.location.isMarked = [NSNumber numberWithBool:YES];
    }
    self.location.timestamp = [NSDate date];
    
    [self.delegate reloadTableViewCell:self];
}

@end
