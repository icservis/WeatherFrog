//
//  DetailViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 23.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak) IBOutlet NSTabViewItem *collectionTabViewItem;
@property (weak) IBOutlet NSTabViewItem *graphTabViewItem;
@property (weak) IBOutlet NSView *collectionTabView;
@property (weak) IBOutlet NSView *graphTabView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)viewModeControlDidChangeValue:(id)sender
{
    DDLogVerbose(@"");
    NSSegmentedControl* viewModeControl = (NSSegmentedControl*)sender;
    [self.tabView selectTabViewItemAtIndex:viewModeControl.selectedSegment];
}

@end
