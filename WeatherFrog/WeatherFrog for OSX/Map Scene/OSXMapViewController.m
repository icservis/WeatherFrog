//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 23.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXMapViewController.h"
#import "OSXAppDelegate.h"
#import "PositionManager.h"
#import "MKMapAnnotation.h"

static float const kMapRadiusMultiplier = 1000.0f;

@interface OSXMapViewController () <MKMapViewDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet MKMapView *mapView;
@property (weak) IBOutlet NSButton *closeButton;
@property (weak) IBOutlet NSSearchField *searchField;

@property (nonatomic, strong) CLGeocoder* geocoder;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;
@property (nonatomic, strong) NSString* selectedTimezoneId;

- (IBAction)closeButtonClicked:(id)sender;

@end

@implementation OSXMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
    
    [self mapView:self.mapView setRegionWithPosition:selectedPosition];
    [self mapView:self.mapView searchAnnotationStored:selectedPosition];
}

#pragma mark - IBActions

- (IBAction)showForecast:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mapViewController:didSelectPosition:bookmark:)]) {
        _selectedPosition = [[PositionManager sharedManager] positionForPlacemark:self.selectedPlacemark timezoneId:self.selectedTimezoneId];
        [self.delegate mapViewController:self didSelectPosition:self.selectedPosition bookmark:NO];
        [self closeButtonClicked:nil];
    }
}

- (IBAction)addPosition:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mapViewController:didSelectPosition:bookmark:)]) {
        _selectedPosition = [[PositionManager sharedManager] positionForPlacemark:self.selectedPlacemark timezoneId:self.selectedTimezoneId];
        [self.delegate mapViewController:self didSelectPosition:self.selectedPosition bookmark:YES];
        [self closeButtonClicked:nil];
    }
}

- (IBAction)closeButtonClicked:(id)sender
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
{;
    [self.geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark* placemark = placemarks[0];
            [self mapView:self.mapView setRegionWithPlacemark:placemark];
            [self mapView:self.mapView searchAnnotation:placemark];
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
            
            NSButton *positionButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 44, 44)];
            [positionButton setTitle: @"+"];
            [positionButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
            [positionButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
            
            [positionButton setTarget:self];
            [positionButton setAction:@selector(addPosition:)];
            annotationPinView.leftCalloutAccessoryView = positionButton;
            
            NSButton *forecastButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 44, 44)];
            [forecastButton setTitle: @"?"];
            [forecastButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
            [forecastButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
            
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
        
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0) {
                CLPlacemark* placemark = placemarks[0];
                [self mapView:self.mapView searchAnnotation:placemark];
            };
        }];
    }
}

#pragma mark  NSSearchField

- (void)textDidEndEditing:(NSNotification *)notification
{
    DDLogVerbose(@"%@", notification);
}

- (void)textDidChange:(NSNotification *)notification
{
    DDLogVerbose(@"%@", notification);
    
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    //DDLogVerbose(@"%@", notification);
    [self mapView:self.mapView searchText:self.searchField.stringValue];
    
}

@end
