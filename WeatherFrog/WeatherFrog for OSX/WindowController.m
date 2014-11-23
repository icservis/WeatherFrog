//
//  WindowController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "WindowController.h"

@interface WindowController ()
@property (weak) IBOutlet NSToolbar *toolBar;
@property (weak) IBOutlet NSToolbarItem *progressToolBarItem;
@property (weak) IBOutlet NSProgressIndicator* progressIndicator;
@property (weak) IBOutlet NSSegmentedControl *viewModeControl;
@property (weak) IBOutlet NSButton *addButton;

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.window.titleVisibility = NSWindowTitleHidden;
    NSLog(@"%@", self.contentViewController);
};

@end
