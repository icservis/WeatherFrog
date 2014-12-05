//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotationButton.h"
#import "MKMapAnnotation.h"
#import "MapGestureRecogniser.h"

static float const kMapRadiusMultiplier = 1000.0f;
static double const kPointHysteresis = 1.0;

@interface MapViewController () <MapGestureRecogniserDelegate>

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;
    
    self.pinGestureRecognizer = [[MapGestureRecogniser alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.pinGestureRecognizer.delegate = self;
}

#if TARGET_OS_IPHONE

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView addGestureRecognizer:self.pinGestureRecognizer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.mapView removeGestureRecognizer:self.pinGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showSelectedPosition];
}

#elif TARGET_OS_MAC

- (void)viewWillAppear
{
    [super viewWillAppear];
    //[self.view addGestureRecognizer:self.pinGestureRecognizer];
}

- (void)viewDidDisappear
{
    [super viewDidDisappear];
    //[self.view removeGestureRecognizer:self.pinGestureRecognizer];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self showSelectedPosition];
}

#endif

- (void)closeController
{
    if (self.closeBlock != nil) {
        self.closeBlock();
    }
}

#pragma mark - Getter and Setters

- (CLGeocoder*)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)setSelectedPosition:(Position *)selectedPosition
{
    _selectedPosition = selectedPosition;
}

#pragma mark - IBActions

- (IBAction)addPosition:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mapViewController:didSelectPosition:bookmark:)]) {
        _selectedPosition = [[PositionManager sharedManager] positionForPlacemark:self.selectedPlacemark timezoneId:self.selectedTimezoneId];
        [self.delegate mapViewController:self didSelectPosition:self.selectedPosition bookmark:YES];
        [self closeController];
    }
}

#pragma mark - MKMapView

- (void)showSelectedPosition
{
    if (self.selectedPosition != nil) {
        [self mapView:self.mapView setRegionWithPosition:self.selectedPosition];
        [self mapView:self.mapView searchAnnotationStored:self.selectedPosition];
    }
}

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

- (void)mapView:(MKMapView *)mapView searchText:(NSString*)text completionBlock:(void (^)(BOOL, NSError *))completionBlock
{
    [self.geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if ([placemarks count] > 0) {
            CLPlacemark* placemark = placemarks[0];
            [self mapView:self.mapView setRegionWithPlacemark:placemark];
            [self mapView:self.mapView searchAnnotation:placemark];
            completionBlock(YES, nil);
        } else {
            if (error != nil) {
                DDLogError(@"error: %@", error);
                completionBlock(NO, error);
            } else {
                completionBlock(NO, nil);
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
            annotationPinView.draggable = YES;
            
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
            
            MapAnnotationButton* positionButton = [MapAnnotationButton annotationButtonWithTarget:self action:@selector(addPosition:) type:MapAnnotationButtonCalloutAccessoryViewTypeLeft];
            annotationPinView.leftCalloutAccessoryView = positionButton;
            
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
        [self activityIndicatorIncrementCount];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [self activityIndicatorDecrementCount];
            if ([placemarks count] > 0) {
                CLPlacemark* placemark = placemarks[0];
                [self mapView:self.mapView searchAnnotation:placemark];
            };
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleLongPress:(MapGestureRecogniser *)recognizer
{
    static CGPoint lastTouchPoint;
    
    CGPoint touchPoint = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    if (abs(touchPoint.x-lastTouchPoint.x) < kPointHysteresis && abs(touchPoint.y-lastTouchPoint.y) < kPointHysteresis) {
        
        DDLogInfo(@"Distance under limit");
        
    } else {
        
        [self searchBarResignFirstResponder];
        lastTouchPoint = touchPoint;
        CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self mapView:self.mapView searchAnnotationNotDetermined:location];
        
        [self activityIndicatorIncrementCount];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [self activityIndicatorDecrementCount];
            if ([placemarks count] > 0) {
                CLPlacemark* placemark = placemarks[0];
                [self mapView:self.mapView searchAnnotation:placemark];
            }
        }];
        
    }
}

- (BOOL)gestureRecognizer:(MapGestureRecogniser *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(MapGestureRecogniser *)otherGestureRecognizer
{
    // Return YES to prevent this gesture from interfering with, say, a pan on a map or table view, or a tap on a button in the tool bar.
    return YES;
}

- (BOOL)gestureRecognizer:(MapGestureRecogniser *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(MapGestureRecogniser *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizer:(MapGestureRecogniser *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(MapGestureRecogniser *)otherGestureRecognizer
{
    return NO;
}

#pragma mark - Activity Indicator

- (void)activityIndicatorIncrementCount
{
    
}

- (void)activityIndicatorDecrementCount
{
    
}

#pragma mark - SearchBar

- (void)searchBarResignFirstResponder
{
    
}

@end
