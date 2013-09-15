//
//  FbUserCell.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "FbUserCell.h"
#import "AppDelegate.h"

@interface FbUserCell()

@property (nonatomic, weak) IBOutlet FBProfilePictureView* profileView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;

- (IBAction)loginButtonTapped:(id)sender;

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
        [_loginButton setImage:[UIImage imageNamed:@"checked-30"] forState:UIControlStateNormal];
    } else {
        _profileView.profileID = nil;
        _nameLabel.text = NSLocalizedString(@"User not logged in", nil);
        [_loginButton setImage:[UIImage imageNamed:@"question-30"] forState:UIControlStateNormal];
    }
}

- (IBAction)loginButtonTapped:(id)sender
{
    DDLogInfo(@"loginButtonTapped");
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary<FBGraphUser> * fbUser = [appDelegate fbUser];
    
    if (fbUser == nil) {
        [appDelegate openSession];
    } else {
        [appDelegate closeSession];
    }
}

@end
