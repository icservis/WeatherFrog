//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSMapViewController.h"
#import "IOSAppDelegate.h"
#import "PositionManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MKMapAnnotation.h"

static double const kPointHysteresis = 10.0;
static float const kLongTapDuration = 1.2;
static float const kMapRadiusMultiplier = 1000.0f;

@interface IOSMapViewController () <MKMapViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* closeButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* trackingButton;

@property (nonatomic) MKUserTrackingMode trackingMode;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGestureRecognizer;
@property (nonatomic, strong) CLGeocoder* geocoder;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;
@property (nonatomic, strong) NSString* selectedTimezoneId;

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)trackingButtonTapped:(id)sender;

@end

@implementation IOSMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.trackingMode = MKUserTrackingModeNone;
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = kLongTapDuration;
    self.longPressGestureRecognizer = longPress;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.mapView removeGestureRecognizer:self.longPressGestureRecognizer];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Getter and Setters

- (CLGeocoder*)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
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

- (void)setSelectedPosition:(Position *)selectedPosition
{
    _selectedPosition = selectedPosition;
    
    [self mapView:self.mapView setRegionWithPosition:selectedPosition];
    [self mapView:self.mapView searchAnnotationStored:selectedPosition];
    self.trackingMode = MKUserTrackingModeNone;
}

#pragma mark - IBActions

- (IBAction)showForecast:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mapViewController:didSelectPosition:bookmark:)]) {
        _selectedPosition = [[PositionManager sharedManager] positionForPlacemark:self.selectedPlacemark timezoneId:self.selectedTimezoneId];
        [self.delegate mapViewController:self didSelectPosition:self.selectedPosition bookmark:NO];
        [self closeButtonTapped:nil];
    }
}

- (IBAction)addPosition:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mapViewController:didSelectPosition:bookmark:)]) {
        _selectedPosition = [[PositionManager sharedManager] positionForPlacemark:self.selectedPlacemark timezoneId:self.selectedTimezoneId];
        [self.delegate mapViewController:self didSelectPosition:self.selectedPosition bookmark:YES];
        [self closeButtonTapped:nil];
    }
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

- (IBAction)closeButtonTapped:(id)sender
{
    if (self.closeBlock != nil) {
        self.closeBlock();
    }
}

#pragma mark - MKMapView

- (void)mapView:(MKMapView *)mapView setRegionWithPosition:(Position*)position
{
    CLLocation* location = position.location;
    CLLocationDistance radius = location.horizontalAccuracy * kMapRadiusMultiplier;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView setRegionWithPlacemark:(CLPlacemark*)placemark
{
    CLCircularRegion* region = (CLCircularRegion*)placemark.region;
    CLLocationDistance radius = region.radius;
    MKCoordinateRegion mkRegion = MKCoordinateRegionMakeWithDistance(region.center, radius, radius);
    [self.mapView setRegion:mkRegion animated:YES];
}

- (void)mapView:(MKMapView *)mapView searchText:(NSString*)text
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    [self.geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        if ([placemarks count] > 0) {
            CLPlacemark* placemark = placemarks[0];
            [self mapView:self.mapView setRegionWithPlacemark:placemark];
            [self mapView:self.mapView searchAnnotation:placemark];
            self.trackingMode = MKUserTrackingModeNone;
        } else {
            if (error != nil) {
                DDLogError(@"error: %@", error);
            }
        }
    }];
}

- (void)mapView:(MKMapView *)mapView searchAnnotationStored:(Position*)position
{
    MKMapAnnotation* searchAnnotation = nil;
    
    for (id<MKAnnotation> annotation in [mapView annotations]) {
        if ([annotation isKindOfClass:[MKMapAnnotation class]]) {
            searchAnnotation = (MKMapAnnotation*)annotation;
            [searchAnnotation updateWithPosition:position];
        }
    }
    
    if (searchAnnotation == nil) {
        searchAnnotation = [[MKMapAnnotation alloc] initWithPosition:position];
        [mapView addAnnotation:searchAnnotation];
    }
    [mapView selectAnnotation:searchAnnotation animated:YES];
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
    [mapView selectAnnotation:searchAnnotation animated:YES];
    
    self.selectedPlacemark = placemark;
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
    
    self.selectedPlacemark = nil;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
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
        if ([annotation isKindOfClass:[Position class]]) {
            hasPlacemark = YES;
        }
        
        if (hasPlacemark == YES) {
            
            UIButton* positionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [positionButton addTarget:self action:@selector(addPosition:) forControlEvents:UIControlEventTouchUpInside];
            annotationPinView.leftCalloutAccessoryView = positionButton;
            
            UIButton* forecastButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [forecastButton addTarget:self action:@selector(showForecast:) forControlEvents:UIControlEventTouchUpInside];
            annotationPinView.rightCalloutAccessoryView = forecastButton;
        } else {
            annotationPinView.leftCalloutAccessoryView = nil;
            annotationPinView.rightCalloutAccessoryView = nil;
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
        
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
            if ([placemarks count] > 0) {
                CLPlacemark* placemark = placemarks[0];
                [self mapView:self.mapView searchAnnotation:placemark];
            };
        }];
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self mapView:self.mapView searchText:searchBar.text];
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleLongPress:(UIGestureRecognizer *)recognizer
{
    static CGPoint lastTouchPoint;
    
    CGPoint touchPoint = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    if (abs(touchPoint.x-lastTouchPoint.x) < kPointHysteresis && abs(touchPoint.y-lastTouchPoint.y) < kPointHysteresis) {
        
        DDLogInfo(@"Distace under limit");
        
    } else {
        
        [self. searchBar resignFirstResponder];
        lastTouchPoint = touchPoint;
        CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self mapView:self.mapView searchAnnotationNotDetermined:location];
        
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
            if ([placemarks count] > 0) {
                CLPlacemark* placemark = placemarks[0];
                [self mapView:self.mapView searchAnnotation:placemark];
            }
        }];
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Return YES to prevent this gesture from interfering with, say, a pan on a map or table view, or a tap on a button in the tool bar.
    return YES;
}

@end
