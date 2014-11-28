//
//  CollectionViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionView.h"

@interface CollectionViewController () <NSCollectionViewDelegate>

@property (weak) IBOutlet CollectionView *collectionView;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
