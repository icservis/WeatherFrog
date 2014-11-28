//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 23.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property (weak) IBOutlet NSButton *bookmarkButton;
@property (weak) IBOutlet NSButton *forecastButton;
@property (weak) IBOutlet NSButton *closeButton;
@property (weak) IBOutlet NSSearchField *searchField;
- (IBAction)closeButtonClicked:(id)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)closeButtonClicked:(id)sender
{
    [self.delegate mapViewControllerDidClose:self];
}

@end