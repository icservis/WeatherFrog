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
- (void)bannerErrorMessage:(NSString*)message;

@end

@interface Banner : NSObject <BannerViewDelegate, BannerViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id <BannerDelegate> delegate;
@property (nonatomic, getter = isBannerActive) BOOL bannerActive;
@property (nonatomic, getter = isAdvancedFeaturesActive) BOOL advancedFeaturesActive;

@property (nonatomic, strong) BannerView* bannerViewLandscape;
@property (nonatomic, strong) BannerView* bannerViewPortrait;
@property (nonatomic, strong) BannerViewController* bannerViewController;

+ (Banner *)sharedBanner;
- (void)setupWithDemoPeriod:(NSTimeInterval)expirePeriod alertsCount:(NSUInteger)alertsCount;
- (NSString*)timeRemainingFormatted:(BOOL)shortFormat;

@end
