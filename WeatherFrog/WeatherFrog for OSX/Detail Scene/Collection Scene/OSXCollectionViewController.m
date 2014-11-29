//
//  CollectionViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXCollectionViewController.h"
#import "OSXCollectionView.h"

@interface OSXCollectionViewController () <NSCollectionViewDelegate>

@property (weak) IBOutlet OSXCollectionView *collectionView;

@end

@implementation OSXCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
