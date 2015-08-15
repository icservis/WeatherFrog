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
    
    if (self.selectedPosition == nil) {
        Position* lastUpdatedBookmarkedPosition = [[DataService sharedInstance] lastUpdatedBookmarkedObject];
        if (lastUpdatedBookmarkedPosition) {
            self.selectedPosition = lastUpdatedBookmarkedPosition;
        }
    }
}

- (void)setSelectedPosition:(Position *)selectedPosition
{
    _selectedPosition = selectedPosition;
    //DDLogVerbose(@"%@", selectedPosition.name);
    
    [self activityIndicatorIncrementCount];
    [self forecastForPosition:selectedPosition withCompletionBlock:^(BOOL updated, NSError *error) {
        [self activityIndicatorDecrementCount];
    }];
}

#pragma mark - MapViewControllerDeleagte

- (void)mapViewController:(MapViewController *)controller didSelectPosition:(Position *)position bookmark:(BOOL)shouldBookmark
{
    self.selectedPosition = position;
}

#pragma mark - Forecast

- (void)forecastForPosition:(Position*)position withCompletionBlock:(void(^)(BOOL updated, NSError* error))completionBlock
{
    [[ForecastManager sharedManager] updateForecastForPosition:position withCompletionBlock:^(BOOL updated, NSError *error) {
        completionBlock(updated, error);
    }];
}


#pragma mark - Activity Indicator

- (void)activityIndicatorIncrementCount
{

}

- (void)activityIndicatorDecrementCount
{
    
}

@end
