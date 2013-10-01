//
//  BannerView.h
//  WeatherFrog
//
//  Created by Libor Kučera on 01.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BannerViewDelegate <NSObject>

- (void)bannerViewTapped:(UIView*)view;
- (void)bannerView:(UIView*)view performAction:(id)sender;

@end

@interface BannerView : UIView

@property (nonatomic, weak) id <BannerViewDelegate> delegate;

- (void)setupContent;
- (CGFloat)width;
- (CGFloat)height;

@end
