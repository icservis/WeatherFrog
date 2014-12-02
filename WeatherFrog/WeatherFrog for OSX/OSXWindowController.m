//
//  WindowController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXWindowController.h"
#import "OSXSplitViewController.h"
#import "OSXListViewController.h"
#import "OSXDetailViewController.h"
#import "OSXMapViewController.h"

@interface OSXWindowController () <NSWindowDelegate>

@property (weak) IBOutlet NSToolbar *toolBar;
@property (weak) IBOutlet NSToolbarItem *progressToolBarItem;
@property (weak) IBOutlet NSProgressIndicator* progressIndicator;
@property (weak) IBOutlet NSSegmentedControl *viewModeControl;
@property (weak) IBOutlet NSButton *addButton;

- (IBAction)viewModeControlValueChanged:(id)sender;

@end

@implementation OSXWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.window.titleVisibility = NSWindowTitleHidden;
    [self selectDetailSceneTabViewItemAccordingToViewModeControl];
};


- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PresentMap"]) {
        OSXMapViewController* mapViewController = (OSXMapViewController*)segue.destinationController;
        OSXSplitViewController* splitViewController = (OSXSplitViewController*)self.contentViewController;
        OSXDetailViewController* detailViewController = (OSXDetailViewController*)splitViewController.tabViewItem.viewController;
        mapViewController.delegate = detailViewController;
        __weak typeof(mapViewController) weakMapVC = mapViewController;
        mapViewController.closeBlock = ^() {
            [self.contentViewController dismissViewController:weakMapVC];
            DDLogVerbose(@"Controller closed");
        };
    }
}


- (IBAction)viewModeControlValueChanged:(id)sender
{
    [self selectDetailSceneTabViewItemAccordingToViewModeControl];
}


- (void)selectDetailSceneTabViewItemAccordingToViewModeControl
{
    OSXSplitViewController* splitViewController = (OSXSplitViewController*)self.contentViewController;
    OSXDetailViewController* tabViewController = (OSXDetailViewController*)splitViewController.tabViewItem.viewController;
    tabViewController.selectedTabViewItemIndex = self.viewModeControl.selectedSegment;
}


#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] terminate:self];
}


@end
