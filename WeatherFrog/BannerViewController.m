//
//  BannerViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 01.10.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Banner.h"
#import "BannerViewController.h"
#import "UserDefaultsManager.h"
#import "DDLog.h"

@interface BannerViewController ()

@property (nonatomic, weak) IBOutlet UIButton* closeButton;
@property (nonatomic, weak) IBOutlet UIButton* fullModeButton;
@property (nonatomic, weak) IBOutlet UIButton* advancedFeaturesButton;
@property (nonatomic, weak) IBOutlet UIButton* reloadProductsButton;
@property (nonatomic, weak) IBOutlet UIButton* restoreButton;
@property (nonatomic, weak) IBOutlet UITextView* infoText;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* fullModeLabel;
@property (nonatomic, weak) IBOutlet UILabel* advancedFeaturesLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeRemainingLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeRemainingValue;

@property (nonatomic, strong) NSDateFormatter* localDateFormatter;
@property (nonatomic, strong) NSNumberFormatter* localNumberFormatter;
@property (nonatomic, strong) NSTimer* timer;

- (IBAction)fullModeButtonTapped:(id)sender;
- (IBAction)advancedFeaturesButtonTapped:(id)sender;
- (IBAction)reloadProductsButtonTapped:(id)sender;
- (IBAction)restoreButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;

@end

@implementation BannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    DDLogVerbose(@"viewDidLoad");
    
    self.titleLabel.text = NSLocalizedString(@"Notifications", nil);
    self.timeRemainingLabel.text = NSLocalizedString(@"Time remaining:", nil);
    self.fullModeLabel.text = NSLocalizedString(@"Unlimited notifications", nil);
    self.advancedFeaturesLabel.text = NSLocalizedString(@"Advanced features", nil);
    [self.restoreButton setTitle:NSLocalizedString(@"Restore purcheses", nil) forState:UIControlStateNormal];
    self.timeRemainingValue.text = nil;
    
    if (self.mode == BannerViewControllerModeDynamic) {
        [self dynamicMode];
    } else {
        [self staticMode];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setters and getters

- (void)setMode:(BannerViewControllerMode)mode
{
    DDLogVerbose(@"mode: %d", mode);
    _mode = mode;
    
    if ([self isViewLoaded]) {
        
        if (mode == BannerViewControllerModeDynamic) {
            [self dynamicMode];
        } else {
            [self staticMode];
        }
    }
}

- (void)setProducts:(NSArray *)products
{
    DDLogVerbose(@"_products: %@", [products description]);
    _products = products;
}

- (NSDateFormatter*)localDateFormatter
{
    if (_localDateFormatter == nil) {
        _localDateFormatter = [[NSDateFormatter alloc] init];
        [_localDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_localDateFormatter setTimeStyle:NSDateFormatterLongStyle];
        [_localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return _localDateFormatter;
}

- (NSNumberFormatter*)localNumberFormatter
{
    if (_localNumberFormatter == nil) {
        _localNumberFormatter = [[NSNumberFormatter alloc] init];
        [_localNumberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_localNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    return _localNumberFormatter;
}

#pragma mark - modes

- (void)dynamicMode
{
    [_products enumerateObjectsUsingBlock:^(SKProduct* availableProduct, NSUInteger idx, BOOL *stop) {
        
        if ([availableProduct.productIdentifier isEqualToString:IAP_fullmode]) {
            
            [self.localNumberFormatter setLocale:availableProduct.priceLocale];
            NSString* fullModePrice = [self.localNumberFormatter stringFromNumber:availableProduct.price];
            [self.fullModeButton setTitle:fullModePrice forState:UIControlStateNormal];
            
            *stop = YES;
        }
    }];
    self.fullModeButton.hidden = NO;
    
    [_products enumerateObjectsUsingBlock:^(SKProduct* availableProduct, NSUInteger idx, BOOL *stop) {
        
        if ([availableProduct.productIdentifier isEqualToString:IAP_advancedfeatures]) {
            
            [self.localNumberFormatter setLocale:availableProduct.priceLocale];
            NSString* fullModePrice = [self.localNumberFormatter stringFromNumber:availableProduct.price];
            [self.advancedFeaturesButton setTitle:fullModePrice forState:UIControlStateNormal];
            
            *stop = YES;
        }
    }];
    self.advancedFeaturesButton.hidden = NO;
    
    self.reloadProductsButton.hidden = NO;
    self.restoreButton.hidden = NO;
    
    self.infoText.text = NSLocalizedString(@"Description for dynamic mode", nil);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeRemaining) userInfo:nil repeats:YES];
}

- (void)staticMode
{
    self.fullModeLabel.hidden = YES;
    self.fullModeButton.hidden = YES;
    self.advancedFeaturesLabel.hidden = YES;
    self.advancedFeaturesButton.hidden = YES;
    self.restoreButton.hidden = YES;
    self.reloadProductsButton.hidden = YES;
    
    self.infoText.text = NSLocalizedString(@"Description for static mode", nil);
    [self.timer invalidate];
}

- (void)updateTimeRemaining
{
    self.timeRemainingValue.text = [[Banner sharedBanner] timeRemainingFormatted:YES];
}

#pragma mark - IBActions

- (IBAction)fullModeButtonTapped:(id)sender
{
    [self.delegate bannerViewController:self performAction:sender];
}

- (IBAction)advancedFeaturesButtonTapped:(id)sender
{
    [self.delegate bannerViewController:self performAction:sender];
}

- (IBAction)reloadProductsButtonTapped:(id)sender
{
    self.reloadProductsButton.enabled = NO;
    [self.delegate bannerViewController:self reloadProductsWithSuccess:^{
        self.reloadProductsButton.enabled = YES;
        [self dynamicMode];
    } failure:^{
        self.reloadProductsButton.enabled = YES;
    }];
}

- (IBAction)restoreButtonTapped:(id)sender
{
    [self.delegate bannerViewController:self performAction:sender];
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self.delegate closeBannerViewController:self];
}

@end
