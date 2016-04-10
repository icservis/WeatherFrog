//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 23.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXMapViewController.h"


@interface OSXMapViewController () <NSTextFieldDelegate>

@property (weak) IBOutlet NSButton *closeButton;
@property (weak) IBOutlet NSSearchField *searchField;

- (IBAction)closeButtonClicked:(id)sender;

@end

@implementation OSXMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


#pragma mark - IBActions

- (IBAction)closeButtonClicked:(id)sender
{
    [self closeController];
}

#pragma mark  NSSearchField


- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    //[self.searchField resignFirstResponder];
    if ([self.searchField.stringValue length] > 0) {
        [self mapView:self.mapView searchText:self.searchField.stringValue completionBlock:^(MKLocalSearchResponse* response, NSError *error) {
            
        }];
    }
}

- (void)searchBarResignFirstResponder
{
    [self.searchField resignFirstResponder];
}

@end
