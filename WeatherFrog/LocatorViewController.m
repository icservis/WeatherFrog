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
#import "Location.h"

static double const PointHysteresis = 10.0;
static float const LongTapDuration = 1.2;

@interface LocatorViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* revealButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* trackingButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* mapButton;
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic) MKUserTrackingMode trackingMode;
@property (nonatomic) MKMapType mapType;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGestureRecognizer;

- (IBAction)trackingButtonTapped:(id)sender;
- (IBAction)mapButtonTapped:(id)sender;

@end

@implementation LocatorViewController {
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
    
    self.delegate = (MenuViewController*)self.revealViewController.rearViewController;
    
    self.title = NSLocalizedString(@"Locator", nil);
    
    // Map defaults
    self.trackingMode = MKUserTrackingModeNone;
    self.mapType = MKMapTypeStandard;
    
    // CLGeocoder
    if (geocoder == nil) {
        geocoder = [[CLGeocoder alloc] init];
    }
    
    // UIGestureRecognizer
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = LongTapDuration;
    self.longPressGestureRecognizer = longPress;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_selectedPlacemark != nil) {
        [self mapView:self.mapView setRegionWithPlacemark:_selectedPlacemark];
        [self mapView:self.mapView searchAnnotation:_selectedPlacemark];
        self.trackingMode = MKUserTrackingModeNone;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.mapView removeGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _selectedPlacemark = nil;
    _selectedLocation = nil;
    _longPressGestureRecognizer = nil;
    geocoder = nil;
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

- (void)setMapType:(MKMapType)mapType
{
    _mapType = mapType;
    [self.mapView setMapType:_mapType];
    
    if (mapType == MKMapTypeStandard) {
        self.mapButton.title = NSLocalizedString(@"Standard", nil);
    }
    if (mapType == MKMapTypeHybrid) {
        self.mapButton.title = NSLocalizedString(@"Hybrid", nil);
    }
    if (mapType == MKMapTypeSatellite) {
        self.mapButton.title = NSLocalizedString(@"Satellite", nil);
    }
}

#pragma mark - IBActions

- (IBAction)trackingButtonTapped:(id)sender
{
    DDLogInfo(@"trackingButtonTapped");
    
    if (_trackingMode == MKUserTrackingModeNone) {
        self.trackingMode = MKUserTrackingModeFollow;
    } else if (_trackingMode == MKUserTrackingModeFollow) {
        self.trackingMode = MKUserTrackingModeFollowWithHeading;
    } else {
        self.trackingMode = MKUserTrackingModeNone;
    }
}

- (IBAction)mapButtonTapped:(id)sender
{
    DDLogInfo(@"mapButtonTapped");
    
    if (_mapType == MKMapTypeStandard) {
        self.mapType = MKMapTypeHybrid;
    } else if (self.mapType == MKMapTypeHybrid) {
        self.mapType = MKMapTypeSatellite;
    } else {
        self.mapType = MKMapTypeStandard;
    }
}

- (IBAction)showForecast:(id)sender
{
    DDLogInfo(@"sender: %@", [sender description]);
    
    SWRevealViewController* rvc = self.revealViewController;
    MenuViewController* menuViewController = (MenuViewController*)rvc.rearViewController;
    menuViewController.selectedPlacemark = _selectedPlacemark;
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
                [self mapView:self.mapView setRegionWithPlacemark:placemark];
                [self mapView:self.mapView searchAnnotation:placemark];
                self.trackingMode = MKUserTrackingModeNone;
                
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
    
    _selectedLocation = placemark.location;
    _selectedPlacemark = placemark;
}

- (void)mapView:(MKMapView *)mapView searchAnnotationNotDetermined:(CLLocation*)location
{
    MKMapAnnotation* searchAnnotation = nil;
    
    for (id<MKAnnotation> annotation in [mapView annotations]) {
        if ([annotation isKindOfClass:[MKMapAnnotation class]]) {
            searchAnnotation = (MKMapAnnotation*)annotation;
            [searchAnnotation updateWithLocation:location];
        }
    }
    
    if (searchAnnotation == nil) {
        searchAnnotation = [[MKMapAnnotation alloc] initWithLocation:location];
        [mapView addAnnotation:searchAnnotation];
    }
    
    _selectedLocation = location;
    _selectedPlacemark = nil;
}



#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    DDLogVerbose(@"annotation: %@", [annotation description]);
    if ([annotation isKindOfClass:[MKMapAnnotation class]]) {
        
        static NSString* identifier = @"PurplePin";
        MKPinAnnotationView* annotationPinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationPinView == nil) {
            annotationPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationPinView.pinColor = MKPinAnnotationColorPurple;
            annotationPinView.canShowCallout = YES;
            annotationPinView.animatesDrop = YES;
            [annotationPinView setDraggable:YES];
            
        } else {
            annotationPinView.annotation = annotation;
        }
        
        BOOL hasPlacemark = NO;
        if ([annotation isKindOfClass:[MKMapAnnotation class]]) {
            MKMapAnnotation* mapAnnotation = (MKMapAnnotation*)annotation;
            hasPlacemark = mapAnnotation.hasPlacemark;
        }
        if ([annotation isKindOfClass:[Location class]]) {
            hasPlacemark = YES;
        }
        
        if (hasPlacemark == YES) {
            UIButton* locationButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [locationButton addTarget:self action:@selector(showForecast:) forControlEvents:UIControlEventTouchUpInside];
            annotationPinView.leftCalloutAccessoryView = locationButton;
        } else {
            annotationPinView.leftCalloutAccessoryView = nil;
        }
        
        return annotationPinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) {
        
        MKMapAnnotation* annotation = annotationView.annotation;
        CLLocation* location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        [self mapView:self.mapView searchAnnotationNotDetermined:location];
        
        if ([[self appDelegate] isInternetActive]) {
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if ([placemarks count] > 0) {
                    CLPlacemark* placemark = placemarks[0];
                    [self mapView:self.mapView searchAnnotation:placemark];
                }
            }];
        }
    }
}

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

#pragma mark - UIGestureRecognizerDelegate

- (void)handleLongPress:(UIGestureRecognizer *)recognizer
{
    static CGPoint lastTouchPoint;
    
    CGPoint touchPoint = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    if (abs(touchPoint.x-lastTouchPoint.x) < PointHysteresis && abs(touchPoint.y-lastTouchPoint.y) < PointHysteresis) {
        
        DDLogInfo(@"Distace under limit");
        
    } else {
        
        [self. searchBar resignFirstResponder];
        lastTouchPoint = touchPoint;
        CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self mapView:self.mapView searchAnnotationNotDetermined:location];
        
        if ([[self appDelegate] isInternetActive]) {
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if ([placemarks count] > 0) {
                    CLPlacemark* placemark = placemarks[0];
                    [self mapView:self.mapView searchAnnotation:placemark];
                }
            }];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Return YES to prevent this gesture from interfering with, say, a pan on a map or table view, or a tap on a button in the tool bar.
    return YES;
}

@end
