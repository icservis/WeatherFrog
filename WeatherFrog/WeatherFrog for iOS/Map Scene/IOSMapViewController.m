//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSMapViewController.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface IOSMapViewController () <UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* closeButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* trackingButton;

@property (nonatomic) MKUserTrackingMode trackingMode;

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)trackingButtonTapped:(id)sender;

@end

@implementation IOSMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.trackingMode = MKUserTrackingModeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Setters

- (void)setSelectedPosition:(Position *)selectedPosition
{
    [super setSelectedPosition:selectedPosition];
    self.trackingMode = MKUserTrackingModeNone;
}

- (void)setTrackingMode:(MKUserTrackingMode)trackingMode
{
    _trackingMode = trackingMode;
    if (self.mapView.userTrackingMode != _trackingMode) {
        [self.mapView setUserTrackingMode:_trackingMode];
    }
    
    if (trackingMode == MKUserTrackingModeFollowWithHeading) {
        _trackingButton.title = NSLocalizedString(@"Heading ON", nil);
    } else if (trackingMode == MKUserTrackingModeFollow) {
        _trackingButton.title = NSLocalizedString(@"Tracking ON", nil);
    } else {
        _trackingButton.title = NSLocalizedString(@"Tracking OFF", nil);
    }
}

#pragma mark - User Actions

- (IBAction)closeButtonTapped:(id)sender
{
    [self closeController];
}

- (IBAction)trackingButtonTapped:(id)sender
{
    if (_trackingMode == MKUserTrackingModeNone) {
        self.trackingMode = MKUserTrackingModeFollow;
    } else if (_trackingMode == MKUserTrackingModeFollow) {
        self.trackingMode = MKUserTrackingModeFollowWithHeading;
    } else {
        self.trackingMode = MKUserTrackingModeNone;
    }
}

#pragma mark - MapView Delegate

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode != _trackingMode) {
        self.trackingMode = mode;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self mapView:self.mapView searchText:searchBar.text completionBlock:^(BOOL success, NSError *error) {
        if (success) {
            self.trackingMode = MKUserTrackingModeNone;
        }
    }];
}

#pragma mark - Activity Indicator

- (void)activityIndicatorIncrementCount
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}

- (void)activityIndicatorDecrementCount
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

- (void)searchBarResignFirstResponder
{
    [self.searchBar resignFirstResponder];
}

@end
