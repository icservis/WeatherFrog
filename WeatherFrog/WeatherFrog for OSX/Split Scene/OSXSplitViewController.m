//
//  SplitViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXSplitViewController.h"

@interface OSXSplitViewController () <NSSplitViewDelegate>



@end

@implementation OSXSplitViewController

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

- (void)mapViewControllerDidClose:(OSXMapViewController *)controller
{
    [self dismissViewController:controller];
}

@end
