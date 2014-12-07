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
@property (weak) IBOutlet NSTextField* titleLabel;
@property (weak) IBOutlet NSSegmentedControl *viewModeControl;
@property (weak) IBOutlet NSButton *addButton;

- (IBAction)viewModeControlValueChanged:(id)sender;

@end

@implementation OSXWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.window.titleVisibility = NSWindowTitleHidden;
    [self selectDetailSceneTabViewItemAccordingToViewModeControl];
    
    OSXSplitViewController* splitViewController = (OSXSplitViewController*)self.contentViewController;
    OSXDetailViewController* detailViewController = (OSXDetailViewController*)splitViewController.detailViewItem.viewController;
    
    [detailViewController addObserver:self forKeyPath:kSelectedPositionObserverKeyName options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
};

- (void)dealloc
{
    OSXSplitViewController* splitViewController = (OSXSplitViewController*)self.contentViewController;
    OSXDetailViewController* detailViewController = (OSXDetailViewController*)splitViewController.detailViewItem.viewController;
    [detailViewController removeObserver:self forKeyPath:kSelectedPositionObserverKeyName];
}


- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PresentMap"]) {
        OSXMapViewController* mapViewController = (OSXMapViewController*)segue.destinationController;
        OSXSplitViewController* splitViewController = (OSXSplitViewController*)self.contentViewController;
        OSXDetailViewController* detailViewController = (OSXDetailViewController*)splitViewController.detailViewItem.viewController;
        mapViewController.delegate = detailViewController;
        mapViewController.selectedPosition = detailViewController.selectedPosition;
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
    OSXDetailViewController* tabViewController = (OSXDetailViewController*)splitViewController.detailViewItem.viewController;
    tabViewController.selectedTabViewItemIndex = self.viewModeControl.selectedSegment;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kSelectedPositionObserverKeyName]) {
        static NSString* kNewKey = @"new";
        if ([change[kNewKey] isKindOfClass:[Position class]]) {
            Position* position = (Position*)change[kNewKey];
            self.titleLabel.stringValue = position.name;
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] terminate:self];
}


@end
