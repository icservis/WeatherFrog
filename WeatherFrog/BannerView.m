//
//  BannerView.m
//  WeatherFrog
//
//  Created by Libor Kučera on 01.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Banner.h"
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
        self.titleLabel.text = NSLocalizedString(@"Notification Evaluating Period", nil);
    } else {
        self.titleLabel.text = NSLocalizedString(@"Notification Evaluating Period", nil);
    }
    self.subtitleLabel.text = [[Banner sharedBanner] timeRemainingFormatted:NO];
    [self.actionButton setTitle:NSLocalizedString(@"Buy", nil) forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:kExpiryAlertTimerPeriod/2 target:self selector:@selector(updateTimeRemaining) userInfo:nil repeats:YES];
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

- (void)updateTimeRemaining
{
    self.subtitleLabel.text = [[Banner sharedBanner] timeRemainingFormatted:NO];
}

@end
