//
//  WindowController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "WindowController.h"
#import "SplitViewController.h"
#import "ListViewController.h"
#import "TabViewController.h"
#import "MapViewController.h"

@interface WindowController () <NSWindowDelegate>

@property (weak) IBOutlet NSToolbar *toolBar;
@property (weak) IBOutlet NSToolbarItem *progressToolBarItem;
@property (weak) IBOutlet NSProgressIndicator* progressIndicator;
@property (weak) IBOutlet NSSegmentedControl *viewModeControl;
@property (weak) IBOutlet NSButton *addButton;

- (IBAction)viewModeControlValueChanged:(id)sender;

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.window.titleVisibility = NSWindowTitleHidden;
    [self selectDetailSceneTabViewItemAccordingToViewModeControl];
};


- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PresentMapViewController"]) {
        MapViewController* mapViewController = (MapViewController*)segue.destinationController;
        SplitViewController* splitViewController = (SplitViewController*)self.contentViewController;
        mapViewController.delegate = splitViewController;
    }
}


- (IBAction)viewModeControlValueChanged:(id)sender
{
    [self selectDetailSceneTabViewItemAccordingToViewModeControl];
}


- (void)selectDetailSceneTabViewItemAccordingToViewModeControl
{
    SplitViewController* splitViewController = (SplitViewController*)self.contentViewController;
    TabViewController* tabViewController = (TabViewController*)splitViewController.tabViewItem.viewController;
    tabViewController.selectedTabViewItemIndex = self.viewModeControl.selectedSegment;
}


#pragma mark - NSWindowDelegate


@end
