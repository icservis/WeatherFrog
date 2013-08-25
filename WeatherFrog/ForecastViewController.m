//
//  ForecastViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "Forecast+Fetch.h"
#import "Location+Store.h"
#import "ForecastViewController.h"
#import "MenuViewController.h"
#import "YrApiService.h"
#import "GoogleApiService.h"

@class Forecast;

@interface ForecastViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* revealButtonItem;
@property (nonatomic, weak) IBOutlet UIView* headerBackground;
@property (nonatomic, weak) IBOutlet UILabel* placemarkTitle;
@property (nonatomic, weak) IBOutlet UILabel* statusInfo;
@property (nonatomic, weak) IBOutlet UIProgressView* progressBar;
@property (nonatomic, weak) IBOutlet UITextView* textView;
@property (nonatomic) BOOL observerCurrentLocation;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Forecast", nil);
    
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    self.observerCurrentLocation = YES;
    
    self.delegate = (MenuViewController*)self.revealViewController.rearViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastUpdate:) name:ForecastUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forecastProgress:) name:ForecastProgressNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.selectedForecast == nil) {
        
        Forecast* lastForecast = [Forecast findFirstOrderedByAttribute:@"timestamp" ascending:NO];
        if (lastForecast != nil) {
            [self displayForecast:lastForecast];
        } else {
            [self displayDefaultScreen];
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

#pragma mark - Shared objects

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - Setters and Getters

- (void)setObserverCurrentLocation:(BOOL)observerCurrentLocation
{
    if (_observerCurrentLocation == YES) {
        
        
    } else {
        
        
    }
    _observerCurrentLocation = observerCurrentLocation;
}


- (void)setSelectedPlacemark:(CLPlacemark *)selectedPlacemark
{
    DDLogInfo(@"selectedPlacemark: %@", [selectedPlacemark description]);
    _selectedPlacemark = selectedPlacemark;
}

- (void)setSelectedForecast:(Forecast *)selectedForecast
{
    _selectedForecast = selectedForecast;
    [self displayForecast:_selectedForecast];
}

#pragma mark - Notifications

- (void)locationManagerUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
    //[self displayDefaultScreen];
}

- (void)forecastUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
    NSDictionary* userInfo = notification.userInfo;
    self.selectedForecast = [userInfo objectForKey:@"currentForecast"];
}

- (void)forecastProgress:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    [self updateProgress:[userInfo objectForKey:@"forecastProgress"]];
}


#pragma mark - User Inreface

- (void)displayForecast:(Forecast*)forecast
{
    DDLogInfo(@"forecast: %@", [forecast description]);
    self.placemarkTitle.text = forecast.name;
    self.statusInfo.text = [NSString stringWithDate:forecast.timestamp];
    [self.progressBar setProgress:1.0f animated:YES];
    [self.textView setText:[forecast description]];
}

- (void)displayDefaultScreen
{
    DDLogInfo(@"defaultScreen");
    self.placemarkTitle.text = NSLocalizedString(@"Location not determined", nil);
    self.statusInfo.text = nil;
    [self.progressBar setProgress:0.0f animated:YES];
    self.textView.text = nil;
}

- (void)updateProgress:(NSNumber*)progressNumber
{
    //DDLogVerbose(@"progress: %@", progressNumber);
    float progress = [progressNumber floatValue];
    self.statusInfo.text = [NSString stringWithFormat:@"%.0f%%", 100*progress];
    [self.progressBar setProgress:progress animated:YES];
}

- (void)updateProgressWithError:(NSError*)error
{
    DDLogError(@"Error: %@", [error description]);
    self.statusInfo.text = [error description];
    [self.progressBar setProgress:0.0f animated:YES];
}

@end
