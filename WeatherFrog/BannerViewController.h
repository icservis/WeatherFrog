//
//  BannerViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 01.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BannerViewControllerModeStatic,
    BannerViewControllerModeDynamic
} BannerViewControllerMode;

@protocol BannerViewControllerDelegate <NSObject>

- (void)closeBannerViewController:(UIViewController*)controller;
- (void)bannerViewController:(UIViewController*)controller performAction:(id)sender;

@end

@interface BannerViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id <BannerViewControllerDelegate> delegate;
@property (nonatomic) BannerViewControllerMode mode;

@end
