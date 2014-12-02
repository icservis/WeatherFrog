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

- (void)mapViewControllerDidSelectLocation:(CLLocation *)location storeLocation:(BOOL)shouldStoreLocation
{
    DDLogVerbose(@"location: %@: shouldStoreLocation: %d", location, shouldStoreLocation);
}


@end
