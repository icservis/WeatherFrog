//
//  SplitViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "SplitViewController.h"

@interface SplitViewController () <NSSplitViewDelegate>

@property (weak) IBOutlet NSSplitViewItem *listViewItem;
@property (weak) IBOutlet NSSplitViewItem *detailViewItem;

@end

@implementation SplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - SplitVC Delegate

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    BOOL splitViewCanCollapseSubview = [super splitView:splitView canCollapseSubview:subview];
    return splitViewCanCollapseSubview;
}

- (BOOL)splitView:(NSSplitView*)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    BOOL splitViewShouldHideDividerAtIndex = [super splitView:splitView shouldHideDividerAtIndex:dividerIndex];
    if (splitViewShouldHideDividerAtIndex == YES) {
        splitViewShouldHideDividerAtIndex = NO;
    }
    return splitViewShouldHideDividerAtIndex;
}

#pragma mark - MapVC Delegate

- (void)mapViewControllerDidClose:(MapViewController *)controller
{
    [self dismissViewController:controller];
}

@end
