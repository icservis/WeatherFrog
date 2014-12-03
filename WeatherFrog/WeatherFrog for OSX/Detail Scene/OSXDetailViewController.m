//
//  tabViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXDetailViewController.h"

@interface OSXDetailViewController ()

@property (weak) IBOutlet NSTabViewItem *collectionViewItem;
@property (weak) IBOutlet NSTabViewItem *graphViewItem;

@end

@implementation OSXDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


#pragma mark - MapViewControllerDeleagte

- (void)mapViewController:(MapViewController *)controller didSelectPosition:(Position *)position bookmark:(BOOL)shouldBookmark
{
    DDLogVerbose(@"position: %@: shouldBookmark: %d", position, shouldBookmark);
}


@end
