//
//  ForecastViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "Forecast+Additions.h"
#import "Location+Store.h"
#import "Weather.h"
#import "Astro.h"
#import "ForecastViewController.h"
#import "ForecastCell.h"
#import "MenuViewController.h"
#import "YrApiService.h"
#import "GoogleApiService.h"
#import "CFGUnitConverter.h"

static NSString* const imageLogo = @"logo";
static NSString* const imageWaitingFrogLandscape = @"waiting-frog-landscape";
static NSString* const imageWaitingFrogPortrait = @"waiting-frog-portrait";
static NSString* const ForecastCellIdentifier = @"ForecastCell";
static NSString* const AstroCellIdentifier = @"AstroCell";

static CGFloat const labelTopMargin = 3.0f;
static CGFloat const labelHeight = 21.0f;
static CGFloat const iconTopMargin = 0.0f;
static CGFloat const iconSize = 64.0f;
static CGFloat const timeTopMargin = 0.0f;
static CGFloat const timeHeight = 21.0f;
static CGFloat const tableTopMargin = 0.0f;

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
    
    self.title = NSLocalizedString(@"Forecast", nil);
    
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    self.delegate = (MenuViewController*)self.revealViewController.rearViewController;
    
    //[self displayDefaultScreen];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastUpdate:) name:ForecastUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastProgress:) name:ForecastProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastError:) name:ForecastErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.selectedForecast == nil) {
        
        NSManagedObjectContext* currentContect = [NSManagedObjectContext contextForCurrentThread];
        Forecast* lastForecast = [Forecast findFirstOrderedByAttribute:@"timestamp" ascending:NO inContext:currentContect];
        
        if (lastForecast != nil) {
            
            DDLogInfo(@"forecast restored");
            self.selectedForecast = lastForecast;
            
        } else {
            
            if (self.selectedPlacemark == nil) {
                DDLogInfo(@"placemark not determined");
                [self displayDefaultScreen];
            } else {
                DDLogInfo(@"placemark restored");
                [self displayLoadingScreen];
                [self forecast:_selectedPlacemark forceUpdate:NO];
            }
        }
        
    } else {
        
        [self displayForecast:_selectedForecast];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _selectedForecast = nil;
    _selectedPlacemark = nil;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
    [self displayForecast:_selectedForecast];
}

#pragma mark - Shared objects

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - IBActions

- (IBAction)actionButtonTapped:(id)sender
{
    NSString* shareString = NSLocalizedString(@"My current forecast", nil);
    UIImage* shareImage = [UIImage imageNamed:imageLogo];
    NSURL* shareUrl = [NSURL URLWithString:kAPIHost];
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareImage, shareUrl, nil];
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    //activityViewController.view.tintColor = self.view.tintColor;
    [self presentViewController:activityViewController animated:YES completion:nil];
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
    [self displayLoadingScreen];
    [self forecast:_selectedPlacemark forceUpdate:NO];
}

- (void)setSelectedForecast:(Forecast *)selectedForecast
{
    DDLogVerbose(@"setSelectedForecast: %@", [selectedForecast description]);
    _selectedForecast = selectedForecast;
    _selectedPlacemark = selectedForecast.placemark;
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground && [self isViewLoaded]) {
        [self displayForecast:_selectedForecast];
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

#pragma mark - Notifications

- (void)preferredContentSizeChanged:(NSNotification*)notification {
    // adjust the layout of the cells
    [self.view setNeedsLayout];
}

- (void)locationManagerUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
}

- (void)forecastUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    NSDictionary* userInfo = notification.userInfo;
    if (_useSelectedLocationInsteadCurrenLocation == NO) {
        self.selectedForecast = [userInfo objectForKey:@"currentForecast"];
        
        MenuViewController* menuViewController = (MenuViewController*)self.revealViewController.rearViewController;
        [menuViewController updateCurrentPlacemark:YES];
    }
}

- (void)forecastProgress:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    if (_useSelectedLocationInsteadCurrenLocation == NO) {
        [self updateProgress:[userInfo objectForKey:@"forecastProgress"]];
    }
}

- (void)forecastError:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    if (_useSelectedLocationInsteadCurrenLocation == NO) {
        [self updateProgressWithError:[userInfo objectForKey:@"forecastError"]];
    }
}

#pragma mark - User Interface

- (void)showLoadingLayout
{
    self.loadingView.hidden = NO;
    self.scrollView.hidden = YES;
}

- (void)showForecastLayout
{
    self.loadingView.hidden = YES;
    self.scrollView.hidden = NO;
}

- (void)displayForecast:(Forecast*)forecast
{
    if (forecast.name == nil && forecast.timezone == nil) {
        DDLogInfo(@"forecast empty");
        [self displayDefaultScreen];
        return;
    }
    
    DDLogInfo(@"displayForecast");
    
    self.title = forecast.name;
    [self showForecastLayout];
    
    if (isLandscape) {
        [self setupViewsForLandscape:forecast];
    } else {
        [self setupViewsForPortrait:forecast];
    }
}

- (void)displayDefaultScreen
{
    DDLogInfo(@"displayDefaultScreen");
    
    self.title = NSLocalizedString(@"Location not determined", nil);
    [self showLoadingLayout];
    [self updateProgressViewWithValue:0.0f message:NSLocalizedString(@"Location service disabled", nil)];
}

- (void)displayLoadingScreen
{
    DDLogInfo(@"displayLoadingScreen");
    
    self.title = NSLocalizedString(@"Fetchning forecast…", nil);
    [self showLoadingLayout];
    [self updateProgressViewWithValue:0.0f message:nil];
    
    if (isLandscape) {
        self.loadingImage.image = [UIImage imageNamed:imageWaitingFrogLandscape];
    } else {
        self.loadingImage.image = [UIImage imageNamed:imageWaitingFrogPortrait];
    }
}

- (void)displayRotatingScreen
{
    DDLogInfo(@"displayRotatingScreen");
    [self showLoadingLayout];
    [self updateProgressViewWithValue:0.0f message:NSLocalizedString(@"Rotating…", nil)];
    
    if (isLandscape) {
        self.loadingImage.image = [UIImage imageNamed:imageWaitingFrogLandscape];
    } else {
        self.loadingImage.image = [UIImage imageNamed:imageWaitingFrogPortrait];
    }
}

- (void)updateProgress:(NSNumber*)progressNumber
{
    float progress = [progressNumber floatValue];
    [self updateProgressViewWithValue:progress message:nil];
}

- (void)updateProgressWithError:(NSError*)error
{
    DDLogError(@"Error: %@", [error description]);
    [self updateProgressViewWithValue:0.0f message:[error localizedDescription]];
}

#pragma mark - Progress view

- (void)updateProgressViewWithValue:(float)progress message:(NSString*)message
{
    if (message != nil) {
        self.statusInfo.text = message;
    } else {
        self.statusInfo.text = [NSString stringWithFormat:@"%.0f%%", 100*progress];
    }
    [self.progressBar setProgress:progress animated:YES];
}

#pragma mark - Helpers for Views

- (void)purgeSubViews
{
    for (UIView* subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
}

#pragma mark - Views for Portrait

- (void)setupViewsForPortrait:(Forecast*)forecast
{
    DDLogInfo(@"setupViewsForPortrait");
    [self purgeSubViews];
    
    [self.dateFormatter setTimeZone:forecast.timezone];
    CGRect superViewFrame = self.scrollView.superview.frame;
    CGRect scrollFrame = self.scrollView.frame;
    
    __block CGRect backgroundRect = CGRectMake(0, 0, scrollFrame.size.width, superViewFrame.size.height - scrollFrame.origin.y);
    DDLogVerbose(@"backgroundRect: %@", NSStringFromCGRect(backgroundRect));
    
    dataPortrait = [forecast sortedWeatherDataForPortrait];
    
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
        dayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
        Weather* firstHour = hours[0];
        [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        dayLabel.text = [self.dateFormatter stringFromDate:firstHour.timestamp];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        [dayBackground addSubview:dayLabel];
        
        CGFloat spacer = (backgroundRect.size.width - 3 * iconSize) / 3;
        CGFloat iconOffset = labelTopMargin + labelHeight + iconTopMargin;
        CGFloat timeOffset = iconOffset + iconSize + timeTopMargin;
        
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
        [dayBackground addSubview:timeRight];
        
        CGFloat tableOffset = timeOffset + timeHeight + tableTopMargin;
        CGRect tableFrame = CGRectMake(0, tableOffset, backgroundRect.size.width, backgroundRect.size.height - tableOffset);
        
        UITableView* tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.scrollEnabled = YES;
        tableView.showsVerticalScrollIndicator = YES;
        tableView.userInteractionEnabled = YES;
        tableView.bounces = YES;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = idx;
        UINib *cellNib = [UINib nibWithNibName:ForecastCellIdentifier bundle:nil];
        [tableView registerNib:cellNib forCellReuseIdentifier:ForecastCellIdentifier];
        [dayBackground addSubview:tableView];
        
        [self.scrollView addSubview:dayBackground];
        
    }];
    CGSize contentSize = CGSizeMake(dataPortrait.count * backgroundRect.size.width, backgroundRect.size.height);
    [self.scrollView setContentSize:contentSize];
    DDLogVerbose(@"contentsize: %@", NSStringFromCGSize(contentSize));
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
    [self purgeSubViews];
    
    UITextView* textView = [[UITextView alloc] initWithFrame:self.scrollView.bounds];
    [textView setText:[forecast description]];
    [textView setEditable:NO];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:textView];
}

#pragma mark - UIEvent

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        DDLogInfo(@"shake gesture");
        if (_selectedPlacemark != nil) {
            [self displayLoadingScreen];
            [self forecast:_selectedPlacemark forceUpdate:YES];
        } else {
            self.selectedPlacemark = [[self appDelegate] currentPlacemark];
            DDLogInfo(@"selectedPlacemark: %@", [_selectedPlacemark description]);
            self.useSelectedLocationInsteadCurrenLocation = NO;
        }
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        if (_selectedForecast != nil) {
            [self displayForecast:_selectedForecast];
        }
    }
}

#pragma mark - ForecastManager

- (void)forecast:(CLPlacemark*)placemark forceUpdate:(BOOL)force
{
    DDLogInfo(@"forceUpdate: %d", force);
    DDLogVerbose(@"placemark: %@", [placemark description]);
    ForecastManager* forecastManager = [[ForecastManager alloc] init];
    forecastManager.delegate = self;
    [forecastManager forecastWithPlacemark:placemark timezone:nil forceUpdate:force];
}

#pragma mark - ForecastManagerDelegate

- (void)forecastManager:(id)manager didFinishProcessingForecast:(Forecast *)forecast
{
    DDLogInfo(@"didFinishProcessingForecast");
    self.selectedForecast = forecast;
}

- (void)forecastManager:(id)manager didFailProcessingForecast:(Forecast *)forecast error:(NSError *)error
{
    DDLogError(@"Error: %@", [error description]);
    [self updateProgressWithError:error];
}

- (void)forecastManager:(id)manager updatingProgressProcessingForecast:(float)progress
{
    [self updateProgress:[NSNumber numberWithFloat:progress]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray* currentDay = [dataPortrait objectAtIndex:tableView.tag];
        return currentDay.count;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        NSArray* currentDay = [dataPortrait objectAtIndex:tableView.tag];
        Weather* weather = [currentDay lastObject];
        NSString* tzAbbreviation = [_selectedForecast.timezone abbreviationForDate:weather.timestamp];
        
        [self.dateFormatter setDateFormat:@"D/w"];
        return [NSString stringWithFormat:@"%@: %@, %@: %@", NSLocalizedString(@"Day/Week", nil), [self.dateFormatter stringFromDate:weather.timestamp], NSLocalizedString(@"Timezone", nil), tzAbbreviation];
        
    } else if (section == 1) {
        return NSLocalizedString(@"Sun", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Moon", nil);
    } else {
        return nil;
    }
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        ForecastCell* cell = (ForecastCell *)[tableView dequeueReusableCellWithIdentifier:ForecastCellIdentifier];
        
        cell.timezone = _selectedForecast.timezone;
        NSArray* currentDay = [dataPortrait objectAtIndex:tableView.tag];
        cell.weather = [currentDay objectAtIndex:indexPath.row];
        
        return cell;
        
    } else {
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:AstroCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AstroCellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
        [_selectedForecast.astro enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Astro* astro = (Astro*)obj;
            
            if ([astro.date isEqualToDate:date]) {
                _foundAstro = astro;
                *stop = YES;
            }
        }];
        
        [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Rise", nil);
                if (_foundAstro != nil) {
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:_foundAstro.sunRise];
                }
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Set", nil);
                if (_foundAstro != nil) {
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:_foundAstro.sunSet];
                }
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Noon altitude", nil);
                if (_foundAstro != nil) {
                    cell.detailTextLabel.text = [self.unitsConverter convertDegrees:_foundAstro.noonAltitude];
                }
            }
            
        }
        
        if (indexPath.section == 2) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Rise", nil);
                if (_foundAstro != nil) {
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:_foundAstro.moonRise];
                }
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Set", nil);
                if (_foundAstro != nil) {
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:_foundAstro.moonSet];
                }
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Phase", nil);
                if (_foundAstro != nil) {
                    cell.detailTextLabel.text = _foundAstro.moonPhase;
                }
            }
            
        }
        
        return cell;
    }
}

#pragma mark - DetailViewControllerDelegate

- (void)closeDetailViewController:(UIViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        DDLogVerbose(@"controller: %@", [controller description]);
    }];
}

@end
