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
#import "DDLog.h"

static NSString* const BannerViewNib = @"BannerView";
static NSString* const BannerViewControllerNib = @"BannerViewController";

@interface Banner ()

@property (nonatomic) NSTimeInterval expirePeriod;
@property (nonatomic) NSUInteger alertsCount;

@end

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

- (void)setupWithDemoPeriod:(NSTimeInterval)expirePeriod alertsCount:(NSUInteger)alertsCount
{
    NSDate* expiryDate = [[UserDefaultsManager sharedDefaults] expiryDate];
    DDLogVerbose(@"expiry date: %@", [expiryDate description]);
    
    self.expirePeriod = expirePeriod;
    self.alertsCount = alertsCount;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    if (expiryDate == nil) {
        
        [self setupExpirePeriod:self.expirePeriod alertsCount:self.alertsCount];
        self.bannerActive = YES;
        
    } else {
        
        if ([expiryDate compare:[NSDate date]] == NSOrderedAscending) {
            
            [self expireLimitedPerion];
            self.bannerActive = YES;
            
        } else {
            
            if ([[WeatherfrogInAppPurchaseHelper sharedInstance] productPurchased:IAP_fullmode]) {
                DDLogVerbose(@"IAP_fullmode activated");
                self.bannerActive = NO;
            } else {
                self.bannerActive = YES;
            }
            
            if ([[WeatherfrogInAppPurchaseHelper sharedInstance] productPurchased:IAP_advancedfeatures]) {
                DDLogVerbose(@"IAP_advancedfeatures activated");
                self.advancedFeaturesActive = YES;
            } else {
                self.advancedFeaturesActive = NO;
            }
        }
    }
    
    [self reloadProductsWithSuccess:^{
        DDLogVerbose(@"products loaded");
    } failure:^{
        DDLogError(@"products failed");
    }];
}

#pragma mark - getters and setters

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

- (void)setBannerActive:(BOOL)bannerActive
{
    _bannerActive = bannerActive;
    
    if (bannerActive == YES)
        [self.delegate bannerChangedStatus:BannerModeVisible];
    else
        [self.delegate bannerChangedStatus:BannerModeInvisible];
}

#pragma mark - StoreKit

- (void)storeKitRestorePurchases
{
    DDLogVerbose(@"storeKitRestorePurchases");
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isInternetActive]) {
        
        [[WeatherfrogInAppPurchaseHelper sharedInstance] restoreCompletedTransactions];
        
    } else {
        
        [self.delegate bannerErrorMessage:NSLocalizedString(@"Can not connect to iTunes Store", nil)];
        
    }
}

- (void)storeKitPerformAction:(NSString*)productIdentifier
{
    DDLogVerbose(@"storeKitPerformAction: %@", productIdentifier);
    
    if (_products == nil) {
        [self.delegate bannerErrorMessage:NSLocalizedString(@"Can not connect to iTunes Store", nil)];
        return;
    }
    
    __block SKProduct* product;
    [_products enumerateObjectsUsingBlock:^(SKProduct* availableProduct, NSUInteger idx, BOOL *stop) {
        
        if ([availableProduct.productIdentifier isEqualToString:productIdentifier]) {
            product = availableProduct;
            *stop = YES;
        }
    }];
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isInternetActive]) {
       
            DDLogVerbose(@"product requested: %@", product.productIdentifier);
            [[WeatherfrogInAppPurchaseHelper sharedInstance] buyProduct:product];
        
    } else {
        [self.delegate bannerErrorMessage:NSLocalizedString(@"Can not connect to iTunes Store", nil)];
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

- (void)reloadProductsWithSuccess:(void (^)())success failure:(void (^)())failure
{
    DDLogVerbose(@"reloadProducts");
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isInternetActive]) {
        
        [[WeatherfrogInAppPurchaseHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL scs, NSArray *products) {
            if (scs) {
                _products = products;
                success();
            } else {
                failure();
            }
        }];
        
    } else {
        
        failure();
    }
}

#pragma mark - actions

- (void)setupExpirePeriod:(NSTimeInterval)timeinterval alertsCount:(NSUInteger)alertsCount
{
    DDLogVerbose(@"setupExpirePeriod: %f, count: %d", timeinterval, alertsCount);
    [[UserDefaultsManager sharedDefaults] setLimitedMode:NO];
    
    NSDate* expiryDate = [NSDate dateWithTimeIntervalSinceNow:timeinterval];
    [[UserDefaultsManager sharedDefaults] setExpiryDate:expiryDate];
    
    NSDate* nextExpireAlertDate = [NSDate dateWithTimeIntervalSinceNow:timeinterval/alertsCount];
    [[UserDefaultsManager sharedDefaults] setNextExpiryAlertDate:nextExpireAlertDate];
}

- (void)expireLimitedPerion
{
    DDLogVerbose(@"expireLimitedPerion");
    
    [[UserDefaultsManager sharedDefaults] setLimitedMode:YES];
    [[UserDefaultsManager sharedDefaults] setFetchForecastInBackground:NO];
    
    [[UserDefaultsManager sharedDefaults] setExpiryDate:nil];
    if ([[UserDefaultsManager sharedDefaults] nextExpiryAlertDate] != nil) {
        
        UIAlertView* expiryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Background notifications", nil) message:NSLocalizedString(@"Evaluating period expired!", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"More…", nil), nil];
        expiryAlertView.tag = 1;
        [expiryAlertView show];
        
    }
    [[UserDefaultsManager sharedDefaults] setNextExpiryAlertDate:nil];
}

- (void)activateFullOperation
{
    DDLogVerbose(@"activateFullOperation");
    
    [[UserDefaultsManager sharedDefaults] setLimitedMode:NO];
    [[UserDefaultsManager sharedDefaults] setFetchForecastInBackground:YES];
    
    [[UserDefaultsManager sharedDefaults] setExpiryDate:[NSDate distantFuture]];
    [[UserDefaultsManager sharedDefaults] setNextExpiryAlertDate:[NSDate distantFuture]];
    
    self.bannerActive = NO;
}

- (void)checkAlertPeriod:(NSTimeInterval)nextExpiryAlertPeriod
{
    DDLogVerbose(@"checkAlertPeriod");
    
    NSDate* nextExpiryAlertDate = [[UserDefaultsManager sharedDefaults] nextExpiryAlertDate];
    DDLogVerbose(@"nextExpiryAlertDate: %@", nextExpiryAlertDate);
    
    if (nextExpiryAlertDate != nil && [nextExpiryAlertDate compare:[NSDate date]] == NSOrderedAscending) {
        DDLogVerbose(@"set next expiry date");
        [[UserDefaultsManager sharedDefaults] setNextExpiryAlertDate:[NSDate dateWithTimeInterval:nextExpiryAlertPeriod sinceDate:nextExpiryAlertDate]];
        
        NSString* checkAlertMessage = [NSString stringWithFormat:@"%@ %@", [self timeRemainingFormatted:YES], NSLocalizedString(@"remaining till the end of evaluating period.", nil)];
        UIAlertView* checkPeriodAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Background notifications", nil) message:checkAlertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"More…", nil), nil];
        checkPeriodAlertView.tag = 2;
        [checkPeriodAlertView show];
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    DDLogVerbose(@"applicationDidBecomeActive");
    [self checkAlertPeriod:self.expirePeriod/self.alertsCount];
}

#pragma mark - BannerViewDelegate

- (void)bannerViewTapped:(UIView *)view
{
    self.bannerViewController.products = _products;
    self.bannerViewController.mode = BannerViewControllerModeDynamic;
    [self.delegate bannerPresentModalViewController:self.bannerViewController];
}

- (void)bannerView:(UIView *)view performAction:(id)sender
{
    if (_products != nil) {
        
        [self storeKitPerformAction:IAP_fullmode];
        
    } else {
        
        [self reloadProductsWithSuccess:^{
            
            [self bannerViewTapped:nil];
            
        } failure:^{
            
            [self.delegate bannerErrorMessage:NSLocalizedString(@"Can not connect to iTunes Store", nil)];
        }];
        
    }
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
        [self storeKitRestorePurchases];
    }
    [self.delegate bannerDismisModalViewController];
}

- (void)closeBannerViewController:(UIViewController *)controller
{
    [self.delegate bannerDismisModalViewController];
}

- (void)bannerViewController:(UIViewController *)controller reloadProductsWithSuccess:(void (^)())success2 failure:(void (^)())failure2
{
    [self reloadProductsWithSuccess:^{
        BannerViewController* bannerViewController = (BannerViewController*)controller;
        bannerViewController.products = _products;
        success2();
    } failure:^{
        failure2();
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self bannerViewTapped:nil];
    }
}

#pragma mark - formatters

- (NSString*)timeRemainingFormatted:(BOOL)shortFormat
{
    NSDate* expiryDate = [[UserDefaultsManager sharedDefaults] expiryDate];
    NSDate* todayDate = [NSDate date];
    
    if ([todayDate compare:expiryDate] == NSOrderedDescending) {
        return NSLocalizedString(@"expired", nil);
    }
    
    NSCalendar* sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents* conversionInfo = [sysCalendar components:unitFlags fromDate:todayDate  toDate:expiryDate  options:0];
    
    if (shortFormat == YES) {
        if ([conversionInfo day] > 0) {
            return [NSString stringWithFormat:@"%d %@", [conversionInfo day], NSLocalizedString(@"days", nil)];
        } else {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
        }
    } else {
        if ([conversionInfo day] > 0) {
            return [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"Remaining", nil), [conversionInfo day], NSLocalizedString(@"days", nil)];
        } else {
            return [NSString stringWithFormat:@"%@: %02i:%02i:%02i", NSLocalizedString(@"Remaining time", nil), [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
        }
    }
}

@end
