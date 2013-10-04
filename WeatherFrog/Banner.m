//
//  Banner.m
//  WeatherFrog
//
//  Created by Libor Kučera on 02.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "Banner.h"
#import "WeatherfrogInAppPurchaseHelper.h"

static NSString* const BannerViewNib = @"BannerView";
static NSString* const BannerViewControllerNib = @"BannerViewController";

@implementation Banner {
    NSArray* _products;
}

#pragma mark - logic

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
    NSDate* expiryDate = [[UserDefaultsManager sharedDefaults] expiryDate];
    DDLogVerbose(@"expiry: %@", [expiryDate description]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    if (expiryDate == nil) {
        
        DDLogVerbose(@"setup");
        expiryDate = [NSDate dateWithTimeIntervalSinceNow:timeinterval];
        [[UserDefaultsManager sharedDefaults] setExpiryDate:expiryDate];
        
        [[UserDefaultsManager sharedDefaults] setLimitedMode:NO];
        self.bannerActive = YES;
        
    } else {
        
        if ([expiryDate compare:[NSDate date]] == NSOrderedAscending) {
            
            DDLogVerbose(@"limited period");
            [[UserDefaultsManager sharedDefaults] setLimitedMode:YES];
            [[UserDefaultsManager sharedDefaults] setFetchForecastInBackground:NO];
            self.bannerActive = YES;
            
        } else {
            
            if ([[WeatherfrogInAppPurchaseHelper sharedInstance] productPurchased:IAP_fullmode]) {
                DDLogVerbose(@"IAP_fullmode purchased");
                self.bannerActive = NO;
            } else {
                self.bannerActive = YES;
            }
            
            if ([[WeatherfrogInAppPurchaseHelper sharedInstance] productPurchased:IAP_advancedfeatures]) {
                DDLogVerbose(@"IAP_advancedfeatures purchased");
            } else {
                
            }
        }
    }
    
    [self reloadProducts];
}

#pragma mark - getters

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

#pragma mark - StoreKit

- (void)storeKitResotrePurchases
{
    DDLogVerbose(@"storeKitResotrePurchases");
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isInternetActive]) {
        [[WeatherfrogInAppPurchaseHelper sharedInstance] restoreCompletedTransactions];
    }
}

- (void)storeKitPerformAction:(NSString*)productIdentifier
{
    DDLogVerbose(@"storeKitPerformAction: %@", productIdentifier);
    
    __block SKProduct* product;
    [_products enumerateObjectsUsingBlock:^(SKProduct* availableProduct, NSUInteger idx, BOOL *stop) {
        
        if ([availableProduct.productIdentifier isEqualToString:productIdentifier]) {
            product = availableProduct;
            *stop = YES;
        }
    }];
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isInternetActive] && product != nil) {
       
        DDLogVerbose(@"product requested: %@", product.productIdentifier);
        [[WeatherfrogInAppPurchaseHelper sharedInstance] buyProduct:product];
        
    }
}

- (void)productPurchased:(NSNotification *)notification
{
    NSString * productIdentifier = notification.object;
    DDLogVerbose(@"productIdentifier: %@", productIdentifier);
    
    if ([productIdentifier isEqualToString:IAP_fullmode]) {
        
        [self activateFullOperation];
        self.bannerViewController.mode = BannerViewControllerModeStatic;
        [self.delegate bannerPresentModalViewController:self.bannerViewController];
    }
    
}

- (void)reloadProducts
{
    DDLogVerbose(@"reloadProducts");
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isInternetActive]) {
        [[WeatherfrogInAppPurchaseHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                _products = products;
            }
        }];
    }
}

#pragma mark - actions

- (void)expireLimitedPerion
{
    DDLogVerbose(@"expireLimitedPerion");
    [[UserDefaultsManager sharedDefaults] setLimitedMode:YES];
    [[UserDefaultsManager sharedDefaults] setFetchForecastInBackground:NO];
    [[UserDefaultsManager sharedDefaults] setExpiryDate:nil];
    [self.delegate bannerChangedStatus:BannerModeVisible];
    self.bannerActive = YES;
}

- (void)activateFullOperation
{
    DDLogVerbose(@"activateFullOperation");
    [[UserDefaultsManager sharedDefaults] setLimitedMode:NO];
    [[UserDefaultsManager sharedDefaults] setFetchForecastInBackground:YES];
    [[UserDefaultsManager sharedDefaults] setExpiryDate:[NSDate distantFuture]];
    [self.delegate bannerChangedStatus:BannerModeInvisible];
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
    [self storeKitPerformAction:IAP_fullmode];
}

#pragma mark - BannerViewControlerDelegate

- (void)bannerViewController:(UIViewController *)controller performAction:(id)sender
{
    UIButton* button = (UIButton*)sender;
    if (button.tag == 3) {
        [self storeKitPerformAction:IAP_advancedfeatures];
    }
    if (button.tag == 2) {
        [self storeKitPerformAction:IAP_fullmode];
    }
    if (button.tag == 1) {
        [self storeKitResotrePurchases];
    }
    if (button.tag == 0) {
        [self expireLimitedPerion];
    }
    [self.delegate bannerDismisModalViewController];
}

- (void)closeBannerViewController:(UIViewController *)controller
{
    [self.delegate bannerDismisModalViewController];
}

@end
