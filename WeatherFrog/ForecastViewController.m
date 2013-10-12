//
//  ForecastViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "ForecastManager.h"
#import "Forecast+Additions.h"
#import "Location.h"
#import "Weather.h"
#import "Astro.h"
#import "ForecastViewController.h"
#import "ForecastCell.h"
#import "ForecastHeader.h"
#import "ForecastFooter.h"
#import "MenuViewController.h"
#import "YrApiService.h"
#import "GoogleApiService.h"
#import "CFGUnitConverter.h"
#import "CCHMapsActivity.h"
#import "MBProgressHUD.h"

static NSString* const imageLogo = @"logo";
static NSString* const imageWaitingFrogLandscape = @"waiting-frog-landscape";
static NSString* const imageWaitingFrogPortrait = @"waiting-frog-portrait";

static NSString* const ForecastCellNib = @"ForecastCell";
static NSString* const ForecastCellIdentifier = @"ForecastCell";
static NSString* const ForecastHeaderNib = @"ForecastHeader";
static NSString* const ForecastFooterNib = @"ForecastFooter";

static CGFloat const labelTopMargin = 3.0f;
static CGFloat const labelHeight = 21.0f;
static CGFloat const timeTopMargin = 3.0f;
static CGFloat const timeHeight = 21.0f;
static CGFloat const iconTopMargin = 0.0f;
static CGFloat const iconSize = 64.0f;
static CGFloat const tableTopMargin = 2.0f;

@class Forecast;

@interface ForecastViewController () {
    NSArray* dataPortrait;
    NSArray* dataLandscape;
}

@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) CFGUnitConverter* unitsConverter;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* revealButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* actionButtonItem;
@property (nonatomic, weak) IBOutlet UIView* loadingView;
@property (nonatomic, weak) IBOutlet UIView* headerBackground;
@property (nonatomic, weak) IBOutlet UILabel* statusInfo;
@property (nonatomic, weak) IBOutlet UIProgressView* progressBar;
@property (nonatomic, weak) IBOutlet UIImageView* loadingImage;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) MBProgressHUD* hud;
@property (nonatomic, strong) ForecastManager* forecastManager;
@property (nonatomic, strong) BannerView* bannerView;

- (IBAction)actionButtonTapped:(id)sender;

@end

@implementation ForecastViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIApplicationDelegate

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.restorationClass = [self class];
    
    self.loadingView.hidden = NO;
    self.scrollView.hidden = NO;
    
    self.title = NSLocalizedString(@"Forecast", nil);
    [self becomeFirstResponder];
    
    [[Banner sharedBanner] setDelegate:self];
        
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdateUnderTreshold:) name:LocationManagerUpdateUnderTresholdNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderFail:) name:ReverseGeocoderFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastFetch:) name:ForecastFetchNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastUpdate:) name:ForecastUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastProgress:) name:ForecastProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastError:) name:ForecastErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DDLogInfo(@"ForecastStatus: %i", self.forecastManager.status);
    
    if (self.forecastManager.status == ForecastStatusLoaded || self.forecastManager.status == ForecastStatusIdle) {
        
        [self displayLoadedScreen];
        
    } else if (self.forecastManager.status == ForecastStatusFailed) {
        
        [self displayFailedScreen];
        
    } else {
        
        [self displayLoadingScreen];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"viewDidAppear");
    [self becomeFirstResponder];
    
    if (self.selectedForecast == nil) {
        
        DDLogVerbose(@"selectedForecast is nil");
        
        if (self.selectedPlacemark == nil) {
            
            Forecast* lastForecast = [self.forecastManager lastForecast];
            
            if (lastForecast != nil) {
                
                if (self.forecastManager.status != ForecastStatusFailed) {
                    DDLogVerbose(@"forecast restored");
                    self.selectedForecast = lastForecast;
                }
                
            } else {
                
                DDLogVerbose(@"placemark not determined");
                [self displayDefaultScreen];
            }
        }
        
    } else {
        
        if (self.forecastManager.status == ForecastStatusCompleted || self.forecastManager.status == ForecastStatusLoaded || self.forecastManager.status == ForecastStatusIdle) {
            DDLogVerbose(@"display selectedForecast");
            [self displayForecast:self.selectedForecast];
        }
    }
}

- (void)viewDidLayoutSubviews
{
    DDLogVerbose(@"viewDidLayoutSubviews");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _selectedForecast = nil;
    _selectedPlacemark = nil;
    dataPortrait = nil;
    dataLandscape = nil;
    _bannerView = nil;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)setRevealMode:(BOOL)revealed
{
    if (revealed == YES) {
        self.scrollView.scrollEnabled = NO;
        [self.scrollView addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    } else {
        self.scrollView.scrollEnabled = YES;
        [self.scrollView removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        
        UINavigationController* detailNavController = (UINavigationController*)segue.destinationViewController;
        DetailViewController* detailViewController = (DetailViewController*)[[detailNavController viewControllers] objectAtIndex:0];
        detailViewController.delegate = self;
        
        ForecastCell* cell = (ForecastCell*)sender;
        detailViewController.weather = cell.weather;
        detailViewController.timezone = self.selectedForecast.timezone;
    }
}

+ (UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    DDLogVerbose(@"viewControllerWithRestorationIdentifierPath %@", identifierComponents);
    UIViewController* viewController = nil;
    NSString* identifier = [identifierComponents lastObject];
    UIStoryboard* storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    
    if (storyboard != nil) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        if (viewController != nil) {
            DDLogVerbose(@"viewController: %@", [viewController description]);
        }
    }
    
    return viewController;
}

- (BOOL)isViewVisible
{
    return [self isViewLoaded];
}

#pragma mark - UIDeviceDelegate

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self displayRotatingScreen];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self displayForecast:self.selectedForecast];
}

#pragma mark - Shared objects

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - IBActions

- (IBAction)actionButtonTapped:(id)sender
{
    NSString* shareString = [self.selectedPlacemark subTitle];
    UIImage* shareImage = [self screenshotOnMask];
    NSURL* shareUrl = [NSURL URLWithString:kAPIHost];
    
    MKPlacemark* placemark = [[MKPlacemark alloc] initWithPlacemark:self.selectedPlacemark];
    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = [self.selectedPlacemark title];
    
    NSArray* activityItems = [NSArray arrayWithObjects:shareString, shareImage, shareUrl, mapItem, self.selectedPlacemark, nil];
    CCHMapsActivity* mapsActivity = [[CCHMapsActivity alloc] init];
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[mapsActivity]];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];

    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Screenshot

- (UIImage*)screenshot
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGSize screenSize;
    
    if (isLandscape) {
        screenSize = CGSizeMake(screenRect.size.height, screenRect.size.width);
    } else {
        screenSize = CGSizeMake(screenRect.size.width, screenRect.size.height);
    }
        
    UIGraphicsBeginImageContext(screenSize);
    [self.navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenshot;
}

- (UIImage*)screenshotOnMask
{
    UIImage* screenshot = [self screenshot];
    UIImage* mask;
    
    CGFloat maskHorizontalOffset = 0;
    CGFloat maskVerticalOffset = 0;
    
    if (isLandscape) {
        mask = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"model-landscape", @"model-landscape-568h")];
        maskHorizontalOffset = 140;
        maskVerticalOffset = 40;
    } else {
        mask = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"model", @"model-568h")];
        maskHorizontalOffset = 40;
        maskVerticalOffset = 140;
    }
    
    
    CGImageRef maskImageRef = mask.CGImage;
    CGFloat maskWidth = CGImageGetWidth(maskImageRef);
    CGFloat maskHeight = CGImageGetHeight(maskImageRef);
    
    // get size of the second image
    CGImageRef screenshotImageRef = screenshot.CGImage;
    CGFloat screenshotWidth = CGImageGetWidth(screenshotImageRef);
    CGFloat screenshotHeight = CGImageGetHeight(screenshotImageRef);
    
    DDLogInfo(@"mask %@", NSStringFromCGSize(CGSizeMake(maskWidth, maskHeight)));
    DDLogInfo(@"screenshot %@", NSStringFromCGRect(CGRectMake(maskHorizontalOffset, maskVerticalOffset, screenshotWidth, screenshotHeight)));
    
    
    CGSize maskSize = CGSizeMake(maskWidth, maskHeight);
    UIGraphicsBeginImageContext(maskSize);
    
    [mask drawInRect:CGRectMake(0, 0, maskWidth, maskHeight)];
    [screenshot drawInRect:CGRectMake(maskHorizontalOffset, maskVerticalOffset, screenshotWidth, screenshotHeight)];
    
    UIImage* mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mergedImage;
}

#pragma mark - Setters and Getters

- (void)setUseSelectedLocationInsteadCurrenLocation:(BOOL)useSelectedLocationInsteadCurrenLocation
{
    DDLogVerbose(@"useSelectedLocationInsteadCurrenLocation: %d", useSelectedLocationInsteadCurrenLocation);
    _useSelectedLocationInsteadCurrenLocation = useSelectedLocationInsteadCurrenLocation;
}

- (void)setSelectedPlacemark:(CLPlacemark *)selectedPlacemark
{
    DDLogVerbose(@"selectedPlacemark: %@", [selectedPlacemark description]);
    _selectedPlacemark = selectedPlacemark;
    [self forecast:selectedPlacemark forceUpdate:NO];
}

- (void)setSelectedForecast:(Forecast *)selectedForecast
{
    DDLogVerbose(@"setSelectedForecast: %@", [selectedForecast description]);
    _selectedForecast = selectedForecast;
    _selectedPlacemark = selectedForecast.placemark;
    dataPortrait = [selectedForecast sortedWeatherDataForPortrait];
    dataLandscape = [selectedForecast sortedWeatherDataForLandscape];
    
    MenuViewController* menuViewController = (MenuViewController*)self.revealViewController.rearViewController;
    [menuViewController updatePlacemark:selectedForecast.placemark];
    
    if ([self isViewVisible]) {
        [self displayForecast:selectedForecast];
    }
}

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (CFGUnitConverter*)unitsConverter
{
    if (_unitsConverter == nil) {
        _unitsConverter = [[CFGUnitConverter alloc] init];
    }
    return _unitsConverter;
}

- (ForecastManager*)forecastManager
{
    if (_forecastManager == nil) {
        _forecastManager = [[ForecastManager alloc] init];
        _forecastManager.delegate = self;
    }
    return _forecastManager;
}

- (BannerView*)bannerView
{
    DDLogVerbose(@"bannerView");
    if (_bannerView == nil) {
        if (isLandscape) {
            _bannerView = [[Banner sharedBanner] bannerViewLandscape];
        } else {
            _bannerView = [[Banner sharedBanner] bannerViewPortrait];
        }
    }
    return _bannerView;
}

#pragma mark - Notifications

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    
    // refreshing portrait
    
    [[self.scrollView subviews] enumerateObjectsUsingBlock:^(UIView* dayBackground, NSUInteger idx, BOOL *stopx) {
        
        [[dayBackground subviews] enumerateObjectsUsingBlock:^(UIView* subView, NSUInteger idy, BOOL *stopy) {
            
            if ([subView isKindOfClass:[UITableView class]]) {
                UITableView* tableView = (UITableView*)subView;
                [tableView reloadData];
            }
            
            if ([subView isKindOfClass:[UILabel class]]) {
                UILabel* label = (UILabel*)subView;
                
                if (label.tag == 0) {
                    [label setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
                } else {
                    [label setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
                }
            }
            
        }];
        
    }];
}

- (void)resignActive:(NSNotification*)notification
{
    DDLogInfo(@"resignActive");
    if (self.presentedViewController != nil && ![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{
            DDLogVerbose(@"dismissed");
        }];
    }
}

- (void)locationManagerUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    [self infoMessage:@"Location update"];
}

- (void)locationManagerUpdateUnderTreshold:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    [self infoMessage:@"location under treshold"];
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    [self infoMessage:@"Geocoder update"];
}

- (void)reverseGeocoderFail:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    [self infoMessage:@"Geocoder fail"];
}

- (void)forecastUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    
    if (_useSelectedLocationInsteadCurrenLocation == NO) {
        NSDictionary* userInfo = notification.userInfo;
        self.selectedForecast = [userInfo objectForKey:@"currentForecast"];
    }
}

- (void)forecastFetch:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    
    if (_useSelectedLocationInsteadCurrenLocation == NO) {
        [self displayFetchingScreen];
    }
}

- (void)forecastProgress:(NSNotification*)notification
{
    if (_useSelectedLocationInsteadCurrenLocation == NO) {
        NSDictionary* userInfo = notification.userInfo;
        [self updateProgress:[userInfo objectForKey:@"forecastProgress"]];
    }
}

- (void)forecastError:(NSNotification*)notification
{
    DDLogError(@"notification: %@", [notification description]);
    
    if (_useSelectedLocationInsteadCurrenLocation == NO) {
        NSDictionary* userInfo = notification.userInfo;
        [self updateProgressWithError:[userInfo objectForKey:@"forecastError"]];
    }
}

#pragma mark - User Interface

- (void)infoMessage:(NSString*)message
{
    // Log message
}

- (void)showLoadingLayout
{
    DDLogInfo(@"showLoadingLayout");
    
    if ([self isViewVisible]) {
        
        [UIView beginAnimations:@"ToggleViews" context:nil];
        [UIView setAnimationDuration:kAnimationDuration];
        self.loadingView.alpha = 1.0;
        self.scrollView.alpha = 0.0;
        [UIView commitAnimations];
        
        [self purgeSubViews];
        self.statusInfo.text = nil;
        [self.progressBar setProgress:0.0f animated:NO];
        
        if (isLandscape) {
            self.loadingImage.image = [UIImage imageNamed:imageWaitingFrogLandscape];
        } else {
            self.loadingImage.image = [UIImage imageNamed:imageWaitingFrogPortrait];
        }
    }
}

- (void)showForecastLayout
{
    DDLogInfo(@"showForecastLayout");
    
    if ([self isViewVisible]) {
        
        [self purgeSubViews];
        
        [UIView beginAnimations:@"ToggleViews" context:nil];
        [UIView setAnimationDuration:kAnimationDuration];
        self.loadingView.alpha = 0.0;
        self.scrollView.alpha = 1.0;
        [UIView commitAnimations];
    }
}

- (void)displayForecast:(Forecast*)forecast
{
    DDLogInfo(@"displayForecast");
    
    if ([self isViewVisible]) {
        
        if (forecast.name == nil && forecast.timezone == nil) {
            DDLogInfo(@"forecast empty");
            [self displayDefaultScreen];
            return;
        }
        
        self.title = forecast.name;
        [self showForecastLayout];
        
        if (isLandscape) {
            [self setupViewsForLandscape:forecast];
        } else {
            [self setupViewsForPortrait:forecast];
        }
        
        [self checkForecastLayoutValidity];
    }
}

- (void)displayDefaultScreen
{
    DDLogInfo(@"displayDefaultScreen");
    
    if ([self isViewVisible]) {
        self.title = NSLocalizedString(@"Location not determined", nil);
        [self showLoadingLayout];
        [self updateProgressViewWithValue:0.0f message:nil];
    }
}

- (void)displayOfflineScreen
{
    DDLogInfo(@"displayOfflineScreen");
    
    if ([self isViewVisible]) {
        self.title = NSLocalizedString(@"Internet connection offline", nil);
        [self showLoadingLayout];
        [self updateProgressViewWithValue:0.0f message:nil];
    }
}

- (void)displayLoadedScreen
{
    DDLogInfo(@"displayLoadedScreen");
    
    if ([self isViewVisible]) {
        self.title = NSLocalizedString(@"Forecast loaded", nil);
        [self showLoadingLayout];
        [self updateProgressViewWithValue:1.0f message:nil];
    }
}

- (void)displayFailedScreen
{
    DDLogInfo(@"displayFailedScreen");
    
    if ([self isViewVisible]) {
        self.title = NSLocalizedString(@"Forecast failed", nil);
        [self showLoadingLayout];
        [self updateProgressViewWithValue:0.0f message:nil];
    }
}

- (void)displayLoadingScreen
{
    DDLogInfo(@"displayLoadingScreen");
    
    if ([self isViewVisible]) {
        self.title = NSLocalizedString(@"Loading forecast…", nil);
        [self showLoadingLayout];
        [self updateProgressViewWithValue:0.0f message:nil];
    }
}


- (void)displayFetchingScreen
{
    DDLogInfo(@"displayLoadingScreen");
    
    if ([self isViewVisible]) {
        self.title = NSLocalizedString(@"Fetchning forecast…", nil);
        [self showLoadingLayout];
        [self updateProgressViewWithValue:0.0f message:nil];
    }
}

- (void)displayRotatingScreen
{
    DDLogInfo(@"displayRotatingScreen");
    
    if ([self isViewVisible]) {
        [self showLoadingLayout];
        [self updateProgressViewWithValue:0.0f message:NSLocalizedString(@"Rotating…", nil)];
    }
}

- (void)updateProgress:(NSNumber*)progressNumber
{
    if ([self isViewVisible]) {
        float progress = [progressNumber floatValue];
        [self updateProgressViewWithValue:progress message:nil];
    }
}

- (void)updateProgressWithError:(NSError*)error
{
    DDLogError(@"Error: %@", [error description]);
    
    if ([self isViewVisible]) {
        self.statusInfo.text = NSLocalizedString(@"Processing forecast failed", nil);
        [self.progressBar setProgress:0.0f animated:NO];
    }
}

#pragma mark - Progress view

- (void)updateProgressViewWithValue:(float)progress message:(NSString*)message
{
    if ([self isViewVisible]) {
        if (message != nil) {
            self.statusInfo.text = message;
        } else {
            self.statusInfo.text = [NSString stringWithFormat:@"%.0f%%", 100*progress];
        }
        [self.progressBar setProgress:progress animated:YES];
    }
}

#pragma mark - Helpers for Views

- (void)purgeSubViews
{
    DDLogVerbose(@"purgeSubViews");
    if (self.bannerView.superview != nil) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
    
    for (UIView* subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
}

- (void)checkForecastLayoutValidity
{
    //[self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Views for Portrait

- (void)setupViewsForPortrait:(Forecast*)forecast
{
    DDLogInfo(@"setupViewsForPortrait");
    
    [self.dateFormatter setTimeZone:forecast.timezone];
    CGRect scrollFrame = self.scrollView.frame;
    __block CGRect backgroundRect;
    
    if ([[Banner sharedBanner] isBannerActive] == YES) {
        
        CGRect superViewFrame = self.scrollView.superview.frame;
        CGFloat bannerHeight = [self.bannerView height];
        CGFloat bannerOriginY = superViewFrame.size.height - bannerHeight;
        self.bannerView.frame = CGRectMake(0, bannerOriginY, superViewFrame.size.width, bannerHeight);
        DDLogInfo(@"self.banner.frame: %@", NSStringFromCGRect(self.bannerView.frame));
        [self.scrollView.superview addSubview:self.bannerView];
        
        backgroundRect = CGRectMake(0, 0, scrollFrame.size.width, scrollFrame.size.height - bannerHeight);
        CGSize contentSize = CGSizeMake(dataPortrait.count * backgroundRect.size.width, backgroundRect.size.height - bannerHeight);
        
        [self.scrollView setContentSize:contentSize];
        
    } else {
        
        backgroundRect = CGRectMake(0, 0, scrollFrame.size.width, scrollFrame.size.height);
        CGSize contentSize = CGSizeMake(dataPortrait.count * backgroundRect.size.width, backgroundRect.size.height);
        [self.scrollView setContentSize:contentSize];
    }
    
    [dataPortrait enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray* hours = (NSArray*)obj;
        
        __block NSMutableArray* timesforLeftIcon = [NSMutableArray new];
        __block NSMutableArray* timesforMiddleIcon = [NSMutableArray new];
        __block NSMutableArray* timesforRightIcon = [NSMutableArray new];
        [self.dateFormatter setDateFormat:@"HH"];
        
        [hours enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            Weather* hour = (Weather*)obj;
            NSString* timeString = [self.dateFormatter stringFromDate:hour.timestamp];
            NSInteger hourInt = [timeString integerValue];
            
            if (hourInt < 10) {
                [timesforLeftIcon addObject:hour];
            } else if (hourInt > 17) {
                [timesforRightIcon addObject:hour];
            } else {
                [timesforMiddleIcon addObject:hour];
            }
        }];
        
        backgroundRect.origin.x = idx * backgroundRect.size.width;
        UIView* dayBackground = [[UIView alloc] initWithFrame:backgroundRect];
        dayBackground.tag = idx;
        
        CGRect labelFrame = CGRectMake(0, labelTopMargin, backgroundRect.size.width, labelHeight);
        UILabel* dayLabel = [[UILabel alloc] initWithFrame:labelFrame];
        dayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        dayLabel.tag = 0;
        
        Weather* firstHour = hours[0];
        [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        dayLabel.text = [self.dateFormatter stringFromDate:firstHour.timestamp];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        [dayBackground addSubview:dayLabel];
        
        CGFloat spacer = (backgroundRect.size.width - 3 * iconSize) / 3;
        CGFloat timeOffset = labelTopMargin + labelHeight + timeTopMargin;
        CGFloat iconOffset = timeOffset + timeHeight + iconTopMargin;
        
        
        CGRect iconLeftFrame = CGRectMake(spacer/2, iconOffset, iconSize, iconSize);
        UIImageView* iconLeft = [[UIImageView alloc] initWithFrame:iconLeftFrame];
        iconLeft.contentMode = UIViewContentModeScaleAspectFit;
        iconLeft.image = [self iconNameForTimes:timesforLeftIcon];
        [dayBackground addSubview:iconLeft];
        
        CGRect timeLeftFrame = CGRectMake(iconLeftFrame.origin.x, timeOffset, iconLeftFrame.size.width, timeHeight);
        UILabel* timeLeft = [[UILabel alloc] initWithFrame:timeLeftFrame];
        timeLeft.textAlignment = NSTextAlignmentCenter;
        timeLeft.textColor = [UIColor darkGrayColor];
        timeLeft.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSNumber* tempLeftCelsius = [self temperatureForTimes:timesforLeftIcon];
        if (tempLeftCelsius != nil) {
            timeLeft.text = [self.unitsConverter convertTemperature:tempLeftCelsius];
        } else {
            timeLeft.text = nil;
        }
        timeLeft.tag = 1;
        [dayBackground addSubview:timeLeft];
        
        CGRect iconMiddleFrame = CGRectMake(3*spacer/2+iconSize, iconOffset, iconSize, iconSize);
        UIImageView* iconMiddle = [[UIImageView alloc] initWithFrame:iconMiddleFrame];
        iconMiddle.contentMode = UIViewContentModeScaleAspectFit;
        iconMiddle.image = [self iconNameForTimes:timesforMiddleIcon];
        [dayBackground addSubview:iconMiddle];
        
        CGRect timeMiddleFrame = CGRectMake(iconMiddleFrame.origin.x, timeOffset, iconMiddleFrame.size.width, timeHeight);
        UILabel* timeMiddle = [[UILabel alloc] initWithFrame:timeMiddleFrame];
        timeMiddle.textAlignment = NSTextAlignmentCenter;
        timeMiddle.textColor = [UIColor darkGrayColor];
        timeMiddle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSNumber* tempMiddleCelsius = [self temperatureForTimes:timesforMiddleIcon];
        if (tempMiddleCelsius != nil) {
            timeMiddle.text = [self.unitsConverter convertTemperature:tempMiddleCelsius];
        } else {
            timeMiddle.text = nil;
        }
        timeMiddle.tag = 2;
        [dayBackground addSubview:timeMiddle];
        
        CGRect iconRightFrame = CGRectMake(5*spacer/2+2*iconSize, iconOffset, iconSize, iconSize);
        UIImageView* iconRight = [[UIImageView alloc] initWithFrame:iconRightFrame];
        iconRight.contentMode = UIViewContentModeScaleAspectFit;
        iconRight.image = [self iconNameForTimes:timesforRightIcon];
        [dayBackground addSubview:iconRight];
        
        CGRect timeRightFrame = CGRectMake(iconRightFrame.origin.x, timeOffset, iconRightFrame.size.width, timeHeight);
        UILabel* timeRight = [[UILabel alloc] initWithFrame:timeRightFrame];
        timeRight.textAlignment = NSTextAlignmentCenter;
        timeRight.textColor = [UIColor darkGrayColor];
        timeRight.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSNumber* tempRightCelsius = [self temperatureForTimes:timesforRightIcon];
        if (tempRightCelsius != nil) {
            timeRight.text = [self.unitsConverter convertTemperature:tempRightCelsius];
        } else {
            timeRight.text = nil;
        }
        timeRight.tag = 3;
        [dayBackground addSubview:timeRight];
        
        CGFloat tableOffset = iconOffset + iconSize + tableTopMargin;
        CGRect tableFrame = CGRectMake(0, tableOffset, backgroundRect.size.width, backgroundRect.size.height - tableOffset);
        
        UITableView* tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        
        tableView.translatesAutoresizingMaskIntoConstraints = YES;
        tableView.scrollEnabled = YES;
        tableView.autoresizesSubviews = YES;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.userInteractionEnabled = YES;
        tableView.bounces = YES;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = idx;
        
        UINib* cellNib = [UINib nibWithNibName:ForecastCellNib bundle:nil];
        [tableView registerNib:cellNib forCellReuseIdentifier:ForecastCellIdentifier];
        
        [dayBackground addSubview:tableView];
        
        [self.scrollView addSubview:dayBackground];
        
    }];
}

- (UIImage*)iconNameForTimes:(NSArray*)weatherArray
{
    if (weatherArray != nil) {
        NSInteger count = weatherArray.count;
        if (count == 0) {
            return nil;
        }
        Weather* weather = [weatherArray objectAtIndex:(count/2)];
        
        NSInteger symbol;
        if (weather.symbol1h != nil) {
            symbol = [weather.symbol1h integerValue];
        } else if (weather.symbol2h != nil) {
            symbol = [weather.symbol2h integerValue];
        } else if (weather.symbol3h != nil) {
            symbol = [weather.symbol3h integerValue];
        } else {
            symbol = [weather.symbol6h integerValue];
        }
        BOOL isNight = [weather.isNight boolValue];
        
        NSString* imageName = [NSString stringWithFormat:@"weathericon-%i-%d-80", symbol, isNight];
        return [UIImage imageNamed:imageName];
        
    } else {
        return nil;
    }
}

- (NSNumber*)temperatureForTimes:(NSArray*)weatherArray
{
    if (weatherArray != nil) {
        NSInteger count = weatherArray.count;
        if (count == 0) {
            return nil;
        }
        Weather* weather = [weatherArray objectAtIndex:(count/2)];
        return weather.temperature;
        
    } else {
        return nil;
    }
}

#pragma mark - Views for Landscape

- (void)setupViewsForLandscape:(Forecast*)forecast
{
    DDLogInfo(@"setupViewsForLandscape");
    
    UITextView* textView;
    if ([[Banner sharedBanner] isBannerActive] == YES) {
        
        CGRect superViewFrame = self.scrollView.superview.frame;
        CGFloat bannerHeight = [self.bannerView height];
        CGFloat bannerOriginY = superViewFrame.size.height - bannerHeight;
        self.bannerView.frame = CGRectMake(0, bannerOriginY, superViewFrame.size.width, bannerHeight);
        DDLogInfo(@"self.banner.frame: %@", NSStringFromCGRect(self.bannerView.frame));
        [self.scrollView.superview addSubview:self.bannerView];
        
        CGRect textFrame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height - bannerHeight);
        textView = [[UITextView alloc] initWithFrame:textFrame];
        
    } else {
        
        CGRect textFrame = self.scrollView.bounds;
        textView = [[UITextView alloc] initWithFrame:textFrame];
    }
    
    [textView setText:[forecast description]];
    [textView setEditable:NO];
    textView.translatesAutoresizingMaskIntoConstraints = YES;
    textView.autoresizesSubviews = YES;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.scrollView addSubview:textView];
    [self.scrollView setContentSize:self.scrollView.frame.size];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - UIEvent

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        DDLogInfo(@"shake gesture");
        if (_useSelectedLocationInsteadCurrenLocation == YES) {
            [self forecast:self.selectedPlacemark forceUpdate:YES];
        } else {
            if ([[self appDelegate] restartGeocoder] == NO) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                _hud.delegate = nil;
                _hud.dimBackground = YES;
                _hud.mode = MBProgressHUDModeText;
                _hud.labelText = NSLocalizedString(@"Location not determined", nil);
                [_hud hide:YES afterDelay:kHudDisplayTimeInterval];
            };
        }
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        if (self.selectedForecast != nil) {
            [self displayForecast:self.selectedForecast];
        }
    }
}

#pragma mark - ForecastManager

- (void)forecast:(CLPlacemark*)placemark forceUpdate:(BOOL)force
{
    DDLogInfo(@"forceUpdate: %d", force);
    DDLogVerbose(@"placemark: %@", [placemark description]);
    [self.forecastManager forecastWithPlacemark:placemark timezone:nil forceUpdate:force];
}

#pragma mark - ForecastManagerDelegate

- (void)forecastManager:(id)manager didStartFetchingForecast:(ForecastStatus)status
{
    DDLogInfo(@"didStartFetchingForecast");
    [self displayFetchingScreen];
}

- (void)forecastManager:(id)manager didFinishProcessingForecast:(Forecast *)forecast
{
    DDLogInfo(@"didFinishProcessingForecast");
    self.selectedForecast = forecast;
}

- (void)forecastManager:(id)manager didFailProcessingForecast:(Forecast *)forecast error:(NSError *)error
{
    DDLogError(@"Error: %@", [error description]);
    [self updateProgressWithError:error];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.delegate = nil;
    _hud.dimBackground = YES;
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = NSLocalizedString(@"Fetching forecast failed", nil);
    [_hud hide:YES afterDelay:kHudDisplayTimeInterval];
    
    MenuViewController* menuViewController = (MenuViewController*)self.revealViewController.rearViewController;
    [menuViewController updatePlacemark:_selectedPlacemark];
}

- (void)forecastManager:(id)manager updatingProgressProcessingForecast:(float)progress
{
    [self updateProgress:[NSNumber numberWithFloat:progress]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        ForecastCell* cell = (ForecastCell*)[tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"showDetail" sender:cell];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* currentDay = [dataPortrait objectAtIndex:tableView.tag];
    return currentDay.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [ForecastCell forecastCellHeigh];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ForecastCell* cell = (ForecastCell *)[tableView dequeueReusableCellWithIdentifier:ForecastCellIdentifier forIndexPath:indexPath];
    
    cell.timezone = self.selectedForecast.timezone;
    NSArray* currentDay = [dataPortrait objectAtIndex:tableView.tag];
    cell.weather = [currentDay objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [ForecastHeader forecastHeaderHeight];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:ForecastHeaderNib owner:self options:nil];
    ForecastHeader* header = nibs[0];
    
    NSArray* currentDay = [dataPortrait objectAtIndex:tableView.tag];
    
    header.weather = [currentDay lastObject];
    header.timeZone = self.selectedForecast.timezone;
    
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:ForecastFooterNib owner:self options:nil];
    ForecastFooter* footer = nibs[0];
    
    NSArray* currentDay = [dataPortrait objectAtIndex:tableView.tag];
    Weather* weather = [currentDay lastObject];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:weather.timestamp];
    [components setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate* date = [calendar dateFromComponents:components];
    
    __block Astro* _foundAstro;
    [self.selectedForecast.astro enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Astro* astro = (Astro*)obj;
        
        if ([astro.date isEqualToDate:date]) {
            _foundAstro = astro;
            *stop = YES;
        }
    }];
    
    footer.astro = _foundAstro;
    footer.timeZone = self.selectedForecast.timezone;
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [ForecastFooter forecastFooterHeight];
}

#pragma mark - DetailViewControllerDelegate

- (void)closeDetailViewController:(UIViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self becomeFirstResponder];
    }];
}

#pragma mark - BannerDeleagte

- (void)bannerDidPerformAction:(BannerAction)action
{
    DDLogVerbose(@"action: %d", action);
}

- (void)bannerChangedStatus:(BannerMode)status
{
    DDLogVerbose(@"status: %d", status);
}

- (void)bannerPresentModalViewController:(UIViewController *)controler
{
    DDLogVerbose(@"controler: %@", [controler description]);
    [self presentViewController:controler animated:YES completion:nil];
}

- (void)bannerDismisModalViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self becomeFirstResponder];
    }];
}

- (void)bannerErrorMessage:(NSString *)message
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.delegate = nil;
    _hud.dimBackground = YES;
    _hud.mode = MBProgressHUDModeText;
    _hud.labelText = message;
    [_hud hide:YES afterDelay:kHudDisplayTimeInterval];
}

@end
