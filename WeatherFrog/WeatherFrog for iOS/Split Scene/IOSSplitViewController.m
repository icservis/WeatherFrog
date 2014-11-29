//
//  SplitViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSSplitViewController.h"
#import "IOSListTableViewCell.h"
#import "IOSDetailViewController.h"

@interface IOSSplitViewController () <UISplitViewControllerDelegate>

@end

@implementation IOSSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIContentContainerProtocol

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [[NSNotificationCenter defaultCenter] postNotificationName:KViewControllerWillTrasitionToTraitCollection object:newCollection];
}

@end
