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
#import "Constants.h"

@interface BannerViewController ()

@property (nonatomic, weak) IBOutlet UIButton* closeButton;
@property (nonatomic, weak) IBOutlet UIButton* fullModeButton;
@property (nonatomic, weak) IBOutlet UIButton* reloadProductsButton;
@property (nonatomic, weak) IBOutlet UIButton* restoreButton;
@property (nonatomic, weak) IBOutlet UIView* contentView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* fullModeLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeRemainingLabel;
@property (nonatomic, weak) IBOutlet UILabel* timeRemainingValue;
@property (nonatomic, strong) IBOutlet UITextView* infoTextView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSDateFormatter* localDateFormatter;
@property (nonatomic, strong) NSNumberFormatter* localNumberFormatter;
@property (nonatomic, strong) NSTimer* timer;

- (IBAction)fullModeButtonTapped:(id)sender;
- (IBAction)reloadProductsButtonTapped:(id)sender;
- (IBAction)restoreButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;

@end

@implementation BannerViewController {
    NSTextStorage* _infoTextStorage;
    CGRect _infoTextFrame;
    CGRect _imageViewFrame;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.titleLabel.text = NSLocalizedString(@"Notifications", nil);
    self.timeRemainingLabel.text = NSLocalizedString(@"Time Remaining:", nil);
    self.fullModeLabel.text = NSLocalizedString(@"Unlimited Notifications", nil);
    [self.restoreButton setTitle:NSLocalizedString(@"Restore Purchases", nil) forState:UIControlStateNormal];
    [self.fullModeButton setTitle:NSLocalizedString(@"Buy", nil) forState:UIControlStateNormal];
    
    
    // info text
    
    NSDictionary* attrs = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline], NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:@"…" attributes:attrs];
    
    _infoTextStorage = [NSTextStorage new];
    [_infoTextStorage setAttributedString:attrString];
    
    CGRect newTextViewRect = self.contentView.bounds;
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    CGSize containerSize = CGSizeMake(newTextViewRect.size.width, newTextViewRect.size.height);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_infoTextStorage addLayoutManager:layoutManager];
    
    _infoTextView = [[UITextView alloc] initWithFrame:newTextViewRect textContainer:container];
    _infoTextView.delegate = self;
    _infoTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _infoTextView.editable = NO;
    
    [self.contentView addSubview:_infoTextView];
    
    _imageViewFrame = CGRectMake(0, 0, 100, 100);
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageLogo]];
    _imageView.frame = _imageViewFrame;
    [_imageView sizeToFit];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.clipsToBounds = YES;
    
    UIBezierPath* excludePath = [UIBezierPath bezierPathWithRect:_imageView.frame];
    self.infoTextView.textContainer.exclusionPaths = @[excludePath];
    
    /*
    CALayer* imageViewLayer = [_imageView layer];
    [imageViewLayer setMasksToBounds:YES];
    [imageViewLayer setBorderColor:[UIColor blackColor].CGColor];
    [imageViewLayer setBorderWidth:1.0];
     */
    
    [self.contentView addSubview:_imageView];
    
    NSLayoutConstraint *constraintLeading = [NSLayoutConstraint constraintWithItem:_infoTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    [self.contentView addConstraint:constraintLeading];
    
    NSLayoutConstraint *constraintTrailing = [NSLayoutConstraint constraintWithItem:_infoTextView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    [self.contentView addConstraint:constraintTrailing];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:_infoTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    [self.contentView addConstraint:constraintTop];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:_infoTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    [self.contentView addConstraint:constraintBottom];
    
    NSLayoutConstraint *constraint2Top = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    [self.contentView addConstraint:constraint2Top];
    
    NSLayoutConstraint *constraint2Leading = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    [self.contentView addConstraint:constraint2Leading];
    
    if (self.mode == BannerViewControllerModeDynamic) {
        [self dynamicMode];
    } else {
        [self staticMode];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.mode == BannerViewControllerModeDynamic) {
        self.timeRemainingValue.text = nil;
        [self updateTimeRemaining];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kExpiryAlertTimerPeriod/2 target:self selector:@selector(updateTimeRemaining) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DDLogInfo(@"willRotateToInterfaceOrientation");
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DDLogInfo(@"didRotateFromInterfaceOrientation");
}

- (void)viewDidLayoutSubviews
{
    DDLogInfo(@"viewDidLayoutSubviews");
    [self updateInfoTextView];
}

- (void)updateInfoTextView
{
    DDLogInfo(@"updateInfoTextView");
    
    self.infoTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    [self updateInfoTextView];
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
    self.reloadProductsButton.hidden = NO;
    self.restoreButton.hidden = NO;
    
    self.infoTextView.text = NSLocalizedString(@"WeatherFrog Notifier is running in evaluating period. By purchasing of Unlimited Nofitications you unlock full functionality of Notifier. In case you bought it yet please use Restore Purchase button.", nil);
}

- (void)staticMode
{
    self.fullModeLabel.hidden = YES;
    self.fullModeButton.hidden = YES;
    self.restoreButton.hidden = YES;
    self.reloadProductsButton.hidden = YES;
    self.timeRemainingValue.text = NSLocalizedString(@"Unlimited", nil);
    
    self.infoTextView.text = NSLocalizedString(@"Thank you for supporting us. WeatherFrog Notifier is fully unlocked now. Notifier can be set in Application Settings.", nil);
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
    [self.timer invalidate];
    [self.delegate closeBannerViewController:self];
}

@end

