//
//  LocatorViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "LocatorViewController.h"
#import "MenuViewController.h"
#import "MKMapAnnotation.h"

@interface LocatorViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* revealButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* trackingButton;
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic) BOOL trackingEnabled;

- (IBAction)trackingButtonTapped:(id)sender;

@end

@implementation LocatorViewController {
    NSMutableArray* recentLocations;
    CLGeocoder* geocoder;
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
	// Do any additional setup after loading the view.
    
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector( revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    self.title = NSLocalizedString(@"Locator", nil);
    self.trackingEnabled = NO;
    
    // recent locations
    recentLocations = [[NSMutableArray alloc] init];
    
    // CLGeocoder
    if (geocoder == nil) {
        geocoder = [[CLGeocoder alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Shared objects

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - Tracking

- (void)setTrackingEnabled:(BOOL)trackingEnabled
{
    if (trackingEnabled == NO) {
        _trackingEnabled = NO;
        _trackingButton.title = NSLocalizedString(@"Tracking OFF", nil);
    } else {
        _trackingEnabled = YES;
        _trackingButton.title = NSLocalizedString(@"Tracking ON", nil);
        
        CLLocation* currentLocation = [[self appDelegate] currentLocation];
        [self mapView:self.mapView setRegionWithLocation:currentLocation];
    }
}

#pragma mark - IBActions

- (IBAction)trackingButtonTapped:(id)sender
{
    DDLogInfo(@"trackingButtonTapped");
    self.trackingEnabled = !self.trackingEnabled;
}

- (IBAction)showLocation:(id)sender
{
    DDLogInfo(@"sender: %@", [sender description]);
}

#pragma mark - MKMapView

- (void)mapView:(MKMapView *)mapView setRegionWithLocation:(CLLocation*)location
{
    CLLocationDistance radius = location.horizontalAccuracy * kMapRadiusMultiplier;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView setRegionWithPlacemark:(CLPlacemark*)placemark
{
    CLCircularRegion* region = (CLCircularRegion*)placemark.region;
    CLLocationDistance radius = region.radius;
    MKCoordinateRegion mkRegion =
    MKCoordinateRegionMakeWithDistance(region.center, radius, radius);
    [self.mapView setRegion:mkRegion animated:YES];
}

- (void)mapView:(MKMapView *)mapView searchText:(NSString*)text
{
    DDLogInfo(@"searchText: %@", [text description]);
    
    if ([[self appDelegate] isInternetActive]) {
        
        [geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0) {
                
                CLPlacemark* placemark = placemarks[0];
                DDLogInfo(@"placemark found: %@", [placemark description]);
                [recentLocations addObject:placemark];

                [self mapView:self.mapView setRegionWithPlacemark:placemark];
                [self mapView:self.mapView searchAnnotation:placemark];
                self.trackingEnabled = NO;
                
            }
        }];
        
    }
}

- (void)mapView:(MKMapView *)mapView searchAnnotation:(CLPlacemark*)placemark
{
    MKMapAnnotation* searchAnnotation = nil;
    
    for (id<MKAnnotation> annotation in [mapView annotations]) {
        if ([annotation isKindOfClass:[MKMapAnnotation class]]) {
            searchAnnotation = (MKMapAnnotation*)annotation;
            [searchAnnotation updateWithPlacemark:placemark];
        }
    }
    
    if (searchAnnotation == nil) {
        searchAnnotation = [[MKMapAnnotation alloc] initWithPlacemark:placemark];
        [mapView addAnnotation:searchAnnotation];
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKMapAnnotation class]]) {
        
        static NSString *identifier = @"PurplePin";
        MKPinAnnotationView* annotationViewPin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationViewPin == nil) {
            annotationViewPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationViewPin.enabled = YES;
            annotationViewPin.selected = YES;
            annotationViewPin.pinColor = MKPinAnnotationColorPurple;
            annotationViewPin.canShowCallout = YES;
            annotationViewPin.animatesDrop = YES;
            annotationViewPin.draggable = YES;
            
            UIButton* locationButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [locationButton addTarget:self action:@selector(showLocation:) forControlEvents:UIControlEventTouchUpInside];
            annotationViewPin.leftCalloutAccessoryView = locationButton;
            
        } else {
            annotationViewPin.annotation = annotation;
        }
        return annotationViewPin;
        
    } else {
        
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) {
        
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

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length==0) {
		if ([text isEqualToString:@"\n"]) {
			[searchBar resignFirstResponder];
            
            if ([searchBar.text length] > 0) {
                [self mapView:self.mapView searchText:searchBar.text];
            }
            
			return NO;
		}
	}
	
    return YES;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    DDLogVerbose(@"searchBar textDidChange: %@", searchText);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    DDLogInfo(@"searchBarCancelButtonClicked");
    searchBar.text = nil;
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    DDLogInfo(@"searchBarSearchButtonClicked");
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    DDLogInfo(@"searchBarResultsListButtonClicked");
}

#pragma mark - Notifications

- (void)locationManagerUpdate:(NSNotification*)notification
{
    if (self.trackingEnabled) {
        NSDictionary* userInfo = notification.userInfo;
        CLLocation* currentLocation = [userInfo objectForKey:@"currentLocation"];
        [self mapView:self.mapView setRegionWithLocation:currentLocation];
    }
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    
}

@end
