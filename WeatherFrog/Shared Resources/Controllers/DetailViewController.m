//
//  DetailViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "DetailViewController.h"
#import "ForecastManager.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setSelectedPosition:(Position *)selectedPosition
{
    _selectedPosition = selectedPosition;
    [self forecastForPosition:selectedPosition];
}

#pragma mark - MapViewControllerDeleagte

- (void)mapViewController:(MapViewController *)controller didSelectPosition:(Position *)position bookmark:(BOOL)shouldBookmark
{
    self.selectedPosition = position;
}

#pragma mark - Forecast

- (void)forecastForPosition:(Position*)position
{
    [self activityIndicatorIncrementCount];
    [[ForecastManager sharedManager] updateForecastForPosition:position withCompletionBlock:^(BOOL updated, NSError *error) {
        [self activityIndicatorDecrementCount];
        [self forecastUpdateDidFinish:updated];
    }];
}

- (void)forecastUpdateDidFinish:(BOOL)updated
{
    
}


#pragma mark - Activity Indicator

- (void)activityIndicatorIncrementCount
{
    
}

- (void)activityIndicatorDecrementCount
{
    
}

@end
