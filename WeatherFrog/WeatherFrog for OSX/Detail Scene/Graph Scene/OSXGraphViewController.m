//
//  GraphViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXGraphViewController.h"
#import "OSXGraphView.h"

@interface OSXGraphViewController ()

@property (weak) IBOutlet OSXGraphView *graphView;

@end

@implementation OSXGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[self.graphView.widthConstraint animator] setConstant:1000.0f];
    [[self.graphView.heightConstraint animator] setConstant:1000.0f];
}


- (void)viewWillLayout
{
    
}

@end
