//
//  ViewController.m
//  WeatherFrog for OSX
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXListViewController.h"
#import "OSXListTableView.h"
#import "OSXListTableViewCell.h"
#import "OSXSplitViewController.h"
#import "OSXDetailViewController.h"

@interface OSXListViewController () <NSTableViewDelegate>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSClipView *clipView;
@property (weak) IBOutlet OSXListTableView *listTableView;
@property (strong) IBOutlet NSArrayController *listController;

@end

@implementation OSXListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self.listTableView setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:kPositionPrimarySortKey ascending:NO], [NSSortDescriptor sortDescriptorWithKey:kPositionSecondarySortKey ascending:NO]]];
    
    OSXSplitViewController* splitViewController = (OSXSplitViewController*)self.parentViewController;
    OSXDetailViewController* detailViewController = (OSXDetailViewController*)splitViewController.detailViewItem.viewController;
    [detailViewController addObserver:self forKeyPath:kSelectedPositionObserverKeyName options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc
{
    OSXSplitViewController* splitViewController = (OSXSplitViewController*)self.parentViewController;
    OSXDetailViewController* detailViewController = (OSXDetailViewController*)splitViewController.detailViewItem.viewController;
    [detailViewController removeObserver:self forKeyPath:kSelectedPositionObserverKeyName];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kSelectedPositionObserverKeyName]) {
        static NSString* kNewKey = @"new";
        if ([change[kNewKey] isKindOfClass:[Position class]]) {
            Position* position = (Position*)change[kNewKey];
            NSInteger selectedIndex = [self.listController.arrangedObjects indexOfObject:position];
            if (selectedIndex != NSNotFound) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:selectedIndex];
                [self.listTableView selectRowIndexes:indexSet byExtendingSelection:NO];
            }
        }
    }
}

#pragma mark - TableView Delegate


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    OSXListTableView* listTableView = (OSXListTableView*)notification.object;
    
    if (listTableView.selectedRow > -1) {
        Position* position = self.listController.arrangedObjects[listTableView.selectedRow];
        OSXSplitViewController* splitVC = (OSXSplitViewController*)self.parentViewController;
        OSXDetailViewController* detailVC = (OSXDetailViewController*)splitVC.detailViewItem.viewController;
        detailVC.selectedPosition = position;
    }
}

#pragma mark - menu Actions

- (IBAction)rename:(id)sender
{
    DDLogVerbose(@"");
    
    [self.listTableView editColumn:self.listTableView.selectedColumn row:self.listTableView.selectedRow withEvent:nil select:YES];
}

- (IBAction)delete:(id)sender
{
    DDLogVerbose(@"");
    [self.listController removeObjects:self.listController.selectedObjects];
}

@end
