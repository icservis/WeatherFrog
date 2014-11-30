//
//  ViewController.m
//  WeatherFrog for OSX
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXListViewController.h"

@class OSXListTableView;

@interface OSXListViewController ()

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSClipView *clipView;
@property (weak) IBOutlet OSXListTableView *listTableView;

@end

@implementation OSXListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
