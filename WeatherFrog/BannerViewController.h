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
- (void)bannerViewController:(UIViewController *)controller reloadProductsWithSuccess:(void (^)())success failure:(void (^)())failure;

@end

@interface BannerViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) id <BannerViewControllerDelegate> delegate;
@property (nonatomic) BannerViewControllerMode mode;
@property (nonatomic, strong) NSArray* products;

@end
