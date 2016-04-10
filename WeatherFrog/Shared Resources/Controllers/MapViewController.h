//
//  MapViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PositionManager.h"

#pragma mark - Cross Platform

#if TARGET_OS_IPHONE
    #define MAP_VIEWCONTROLLER_CLASS UIViewController
#elif TARGET_OS_MAC
    #define MAP_VIEWCONTROLLER_CLASS NSViewController
#endif


@class MapViewController;
@class MapGestureRecogniser;

@protocol MapViewControllerDelegate <NSObject>

- (void)mapViewController:(MapViewController*)controller didSelectPosition:(Position*)position bookmark:(BOOL)shouldBookmark;

@end

@interface MapViewController : MAP_VIEWCONTROLLER_CLASS  <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@property (nonatomic, copy) void (^closeBlock)(void);
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLGeocoder* geocoder;
@property (nonatomic, strong) Position* selectedPosition;
@property (nonatomic, strong) CLPlacemark* selectedPlacemark;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) MapGestureRecogniser* pinGestureRecognizer;

- (void)closeController;
- (void)mapView:(MKMapView *)mapView searchText:(NSString*)text completionBlock:(void(^)(MKLocalSearchResponse* reponse, NSError* error))completionBlock;
- (void)mapView:(MKMapView *)mapView searchAnnotationStored:(Position*)position;
- (void)mapView:(MKMapView *)mapView searchAnnotation:(CLPlacemark*)placemark;
- (void)mapView:(MKMapView *)mapView searchAnnotationNotDetermined:(CLLocation*)location;
- (void)activityIndicatorIncrementCount;
- (void)activityIndicatorDecrementCount;
- (void)searchBarResignFirstResponder;

@end
