//
//  BannerView.m
//  WeatherFrog
//
//  Created by Libor Kučera on 01.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "BannerView.h"

@interface BannerView ()

@property (nonatomic, weak) IBOutlet UIImageView* logoView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* subtitleLabel;
@property (nonatomic, weak) IBOutlet UIButton* actionButton;
@property (nonatomic, weak) IBOutlet UIGestureRecognizer* tapRecogrizer;

- (IBAction)actionButtonTapped:(id)sender;
- (IBAction)tapRecognizerTapped:(id)sender;

@end

@implementation BannerView


- (void)setupContent
{
    self.logoView.image = [UIImage imageNamed:@"logo"];
    if (isLandscape) {
        self.titleLabel.text = NSLocalizedString(@"This is a landscape message", nil);
        self.subtitleLabel.text = nil;
    } else {
        self.titleLabel.text = NSLocalizedString(@"This is a portrait message", nil);
        self.subtitleLabel.text = NSLocalizedString(@"This is a portrait note", nil);
    }
    [self.actionButton setTitle:NSLocalizedString(@"Action", nil) forState:UIControlStateNormal];
}

- (IBAction)actionButtonTapped:(id)sender
{
    DDLogVerbose(@"sender: %@", [sender description]);
    [self.delegate bannerView:self performAction:sender];
}

- (IBAction)tapRecognizerTapped:(id)sender
{
    DDLogVerbose(@"sender: %@", [sender description]);
    [self.delegate bannerViewTapped:self];
}

- (CGFloat)width
{
    return self.bounds.size.width;
}

- (CGFloat)height
{
    return self.bounds.size.height;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
