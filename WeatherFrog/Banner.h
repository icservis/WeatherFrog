//
//  Banner.h
//  WeatherFrog
//
//  Created by Libor Kučera on 02.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BannerView.h"
#import "BannerViewController.h"

typedef enum {
    BannerActionDefault,
    BannerActionOption1,
    BannerActionOption2,
    BannerActionOption3
} BannerAction;

typedef enum {
    BannerModeVisible,
    BannerModeInvisible
} BannerMode;

@protocol BannerDelegate <NSObject>

- (void)bannerDidPerformAction:(BannerAction)action;
- (void)bannerPresentModalViewController:(UIViewController*)controler;
- (void)bannerDismisModalViewController;
- (void)bannerChangedStatus:(BannerMode)status;

@end

@interface Banner : NSObject <BannerViewDelegate, BannerViewControllerDelegate>

@property (nonatomic, weak) id <BannerDelegate> delegate;
@property (nonatomic, getter=isBannerActive) BOOL bannerActive;

@property (nonatomic, strong) BannerView* bannerViewLandscape;
@property (nonatomic, strong) BannerView* bannerViewPortrait;
@property (nonatomic, strong) BannerViewController* bannerViewController;

+ (Banner *)sharedBanner;
- (void)setupWithDemoPeriod:(NSTimeInterval)timeinterval alertsCount:(NSUInteger)alertsCount;

// TEST
- (void)expireLimitedPerion;
- (void)activateFullOperation;

@end
