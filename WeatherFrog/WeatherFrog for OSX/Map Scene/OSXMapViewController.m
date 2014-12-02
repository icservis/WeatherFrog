//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 23.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXMapViewController.h"

@interface OSXMapViewController ()

@property (weak) IBOutlet MKMapView *mapView;
@property (weak) IBOutlet NSButton *closeButton;
@property (weak) IBOutlet NSSearchField *searchField;

- (IBAction)closeButtonClicked:(id)sender;

@end

@implementation OSXMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)closeButtonClicked:(id)sender
{
    if (self.closeBlock != nil) {
        self.closeBlock();
    }
}

@end
