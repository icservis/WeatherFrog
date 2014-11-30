//
//  GraphViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXGraphViewController.h"
#import "OSXGraphView.h"

@class OSXFlippedView;

@interface OSXGraphViewController ()

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSClipView *clipView;
@property (weak) IBOutlet OSXFlippedView *contentView;
@property (weak) IBOutlet OSXGraphView *graphView;

@end

@implementation OSXGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}


- (void)viewWillLayout
{
    
}

@end
