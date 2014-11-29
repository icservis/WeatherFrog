//
//  SplitViewController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 22.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSXAppDelegate.h"
#import "OSXMapViewController.h"
#import "OSXListViewController.h"
#import "OSXDetailViewController.h"

@interface OSXSplitViewController : NSSplitViewController <OSXMapViewControllerDelegate>

@property (weak) IBOutlet NSSplitViewItem *listViewItem;
@property (weak) IBOutlet NSSplitViewItem *tabViewItem;

@end
