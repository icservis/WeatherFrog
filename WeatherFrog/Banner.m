//
//  Banner.m
//  WeatherFrog
//
//  Created by Libor Kučera on 02.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Banner.h"

static NSString* const BannerViewNib = @"BannerView";
static NSString* const BannerViewControllerNib = @"BannerViewController";

@implementation Banner

+ (Banner *)sharedBanner {
    
    static Banner* _sharedBanner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBanner = [[self alloc] init];
    });
    
    return _sharedBanner;
}

- (void)setupWithDemoPeriod:(NSTimeInterval)timeinterval alertsCount:(NSUInteger)alertsCount
{
    [[UserDefaultsManager sharedDefaults] setLimitedMode:NO];
    self.bannerActive = YES;
}

- (BannerView*)bannerViewLandscape
{
    if (_bannerViewLandscape == nil) {
        NSString* nibName = [NSString stringWithFormat:@"%@-Landscape", BannerViewNib];
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        _bannerViewLandscape = nibs[0];
        _bannerViewLandscape.delegate = self;
        [_bannerViewLandscape setupContent];
    }
    return _bannerViewLandscape;
}

- (BannerView*)bannerViewPortrait
{
    if (_bannerViewPortrait == nil) {
        NSString* nibName = [NSString stringWithFormat:@"%@-Portrait", BannerViewNib];
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        _bannerViewPortrait = nibs[0];
        _bannerViewPortrait.delegate = self;
        [_bannerViewPortrait setupContent];
    }
    return _bannerViewPortrait;
}

- (BannerViewController*)bannerViewController
{
    if (_bannerViewController == nil) {
        _bannerViewController = [[BannerViewController alloc] initWithNibName:BannerViewControllerNib bundle:nil];
        _bannerViewController.delegate = self;
    }
    return _bannerViewController;
}

- (void)storeKitPerformAction:(id)sender
{
    [self.delegate bannerDismisModalViewController];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", nil) message:NSLocalizedString(@"Perform action?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        
        [self activateFullOperation];
        self.bannerViewController.mode = BannerViewControllerModeStatic;
        [self.delegate bannerPresentModalViewController:self.bannerViewController];
        [self.delegate bannerChangedStatus:BannerModeInvisible];
    }
}

- (void)expireLimitedPerion
{
    [[UserDefaultsManager sharedDefaults] setLimitedMode:YES];
    self.bannerActive = YES;
}

- (void)activateFullOperation
{
    [[UserDefaultsManager sharedDefaults] setLimitedMode:NO];
    self.bannerActive = NO;
}

#pragma mark - BannerViewDelegate

- (void)bannerViewTapped:(UIView *)view
{
    self.bannerViewController.mode = BannerViewControllerModeDynamic;
    [self.delegate bannerPresentModalViewController:self.bannerViewController];
}

- (void)bannerView:(UIView *)view performAction:(id)sender
{
    [self storeKitPerformAction:sender];
}

#pragma mark - BannerViewControlerDelegate

- (void)bannerViewController:(UIViewController *)controller performAction:(id)sender
{
    [self storeKitPerformAction:sender];
}

- (void)closeBannerViewController:(UIViewController *)controller
{
    [self.delegate bannerDismisModalViewController];
}

@end
