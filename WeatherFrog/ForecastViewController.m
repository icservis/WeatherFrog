//
//  ForecastViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "ForecastViewController.h"
#import "MenuViewController.h"

@interface ForecastViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* revealButtonItem;
@property (nonatomic, weak) IBOutlet UITextView* locationTextView;
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
    [self.revealButtonItem setAction: @selector( revealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _locationTextView.text = nil;
    _geocoderTextView.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Shared objects

- (AppDelegate*)appDeleagte
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - Notifications

- (void)locationManagerUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
    NSDictionary* userInfo = notification.userInfo;
    CLLocation* currentLocation = [userInfo objectForKey:@"currentLocation"];
    _locationTextView.text = [currentLocation description];
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
    NSDictionary* userInfo = notification.userInfo;
    CLLocation* currentPlacemark = [userInfo objectForKey:@"currentPlacemark"];
    _geocoderTextView.text = [currentPlacemark description];
}

@end
