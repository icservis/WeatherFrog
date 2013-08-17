//
//  FbUserCell.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "FbUserCell.h"

@interface FbUserCell()

@property (nonatomic, weak) IBOutlet FBProfilePictureView* profileView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;

@end

@implementation FbUserCell

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

- (void)setFbUser:(NSDictionary<FBGraphUser> *)fbUser
{
    DDLogVerbose(@"fbUser: %@", [fbUser description]);
    
    _profileView.pictureCropping = FBProfilePictureCroppingSquare;
    
    if (fbUser != nil) {
        _profileView.profileID = fbUser.id;
        _nameLabel.text = fbUser.name;
    } else {
        _profileView.profileID = nil;
        _nameLabel.text = NSLocalizedString(@"User not logged in", nil);
    }
}

@end
