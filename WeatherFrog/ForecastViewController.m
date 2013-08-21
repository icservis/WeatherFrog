//
//  ForecastViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "Forecast.h"
#import "ForecastViewController.h"
#import "MenuViewController.h"
#import "YrApiService.h"
#import "GoogleApiService.h"

@class Forecast;

@interface ForecastViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* revealButtonItem;
@property (nonatomic, weak) IBOutlet UITextView* geocoderTextView;

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
    
    self.delegate = (MenuViewController*)self.revealViewController.rearViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self performForecastWithPlacemark:_selectedPlacemark];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _forecasts = nil;
    _selectedPlacemark = nil;
    _currentPlacemark = nil;
}

#pragma mark - Shared objects

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - Setters and Getters

- (void)setSelectedPlacemark:(CLPlacemark *)selectedPlacemark
{
    DDLogInfo(@"selectedPlacemark: %@", [selectedPlacemark description]);
    _selectedPlacemark = selectedPlacemark;
    
}

#pragma mark - Forecast

- (void)performForecastWithPlacemark:(CLPlacemark*)placemark
{
    _geocoderTextView.text = [placemark description];
    
    [[YrApiService sharedService] forecastWithLocation:placemark.location success:^(Forecast *forecast) {
        DDLogVerbose(@"forecast: %@", [forecast description]);
    } failure:^{
        DDLogError(@"error");
    }];
}

#pragma mark - Notifications

- (void)locationManagerUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
    NSDictionary* userInfo = notification.userInfo;
    CLPlacemark* currentPlacemark = [userInfo objectForKey:@"currentPlacemark"];
    
    _currentPlacemark = currentPlacemark;
}

@end
