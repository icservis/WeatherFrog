//
//  ViewController.m
//  WeatherFrog for iOS
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSListViewController.h"
#import "IOSListTableView.h"
#import "IOSListTableViewCell.h"
#import "IOSAppDelegate.h"
#import "IOSDetailViewController.h"
#import "IOSSplitViewController.h"

#import "PositionManager.h"
#import "TLIndexPathTools.h"

@interface IOSListViewController () <TLIndexPathControllerDelegate>

@property (strong, nonatomic) TLIndexPathController *indexPathController;

@property (nonatomic, weak) IBOutlet IOSListTableView* tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentPositionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeAllBookmarksButton;

@property (strong, nonatomic) UIBarButtonItem *closeButtonItem;
@property (strong, nonatomic) UITraitCollection* splitViewControllerTraitCollection;

- (IBAction)currentPositionButtonTapped:(id)sender;
- (IBAction)bookmarkButtonTapped:(id)sender;
- (IBAction)removeAllBookmarksButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;

@end

@implementation IOSListViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.splitViewControllerTraitCollection = self.splitViewController.traitCollection;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerWillTrasitionToTraitCollectionNotification:) name:KViewControllerWillTrasitionToTraitCollection object:nil];
    
    DataService* dataService = [DataService sharedInstance];
    
    self.indexPathController = [[TLIndexPathController alloc] initWithFetchRequest:[dataService fetchRequestForAllObjects] managedObjectContext:[dataService managedObjectContext] sectionNameKeyPath:@"isBookmark" identifierKeyPath:nil cacheName:nil];
    self.indexPathController.delegate = self;
    [self.indexPathController performFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[DataService sharedInstance] saveContext];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self setEditing:NO animated:YES];
    
    if ([segue.identifier isEqualToString:@"ReplaceDetail"]) {
        
        if (self.splitViewController.collapsed == NO) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (self.splitViewController.displayModeButtonItem.action != nil) {
                [self.splitViewController.displayModeButtonItem.target performSelector:self.splitViewController.displayModeButtonItem.action withObject:nil];
            }
#pragma clang diagnostic pop
        }
        
        UINavigationController* navigationVC = segue.destinationViewController;
        IOSDetailViewController* detailVC = (IOSDetailViewController*)[[navigationVC viewControllers] firstObject];
        if ([sender isKindOfClass:[IOSListTableViewCell class]]) {
            IOSListTableViewCell* cell = (IOSListTableViewCell*)sender;
            detailVC.selectedPosition = cell.position;
        }
        if ([sender isKindOfClass:[self.currentPositionButton class]]) {
            IOSAppDelegate* appDelegate = (IOSAppDelegate*)[UIApplication sharedApplication].delegate;
            detailVC.selectedPosition = appDelegate.currentPosition;
        }
    }
}

#pragma mark - Setters and Getters

- (UIBarButtonItem*)closeButtonItem
{
    if (_closeButtonItem == nil) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];
    }
    return _closeButtonItem;
}

- (void)setSplitViewControllerTraitCollection:(UITraitCollection *)splitViewControllerTraitCollection
{
    if (_splitViewControllerTraitCollection != splitViewControllerTraitCollection) {
        
        UIUserInterfaceSizeClass splitViewControllerHorizontalClass = [splitViewControllerTraitCollection horizontalSizeClass];
        //UIUserInterfaceSizeClass splitViewControllerVerticalClass = [splitViewControllerTraitCollection verticalSizeClass];
        
        if (splitViewControllerHorizontalClass == UIUserInterfaceSizeClassCompact) {
            self.navigationItem.rightBarButtonItems = @[self.closeButtonItem, self.editButtonItem];
        } else {
            self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [self.navigationController setToolbarHidden:!editing animated:animated];
}


#pragma mark - Notifications

- (void)viewControllerWillTrasitionToTraitCollectionNotification:(NSNotification*)notification
{
    UITraitCollection* splitViewControllerTraitCollection = (UITraitCollection*)notification.object;
    self.splitViewControllerTraitCollection = splitViewControllerTraitCollection;
}

#pragma mark - User Actions

- (IBAction)currentPositionButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"ReplaceDetail" sender:sender];
}

- (IBAction)bookmarkButtonTapped:(id)sender
{
    
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"ReplaceDetail" sender:nil];
}

- (IBAction)removeAllBookmarksButtonTapped:(id)sender
{
    UIAlertController* alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
                                          message:NSLocalizedString(@"Do you really want to erase all bookmarks?", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Confirm", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [[DataService sharedInstance] deleteAllObjects];
                                   [self setEditing:NO animated:YES];
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Cancel", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   DDLogVerbose(@"");
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        DDLogVerbose(@"");
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.indexPathController.dataModel numberOfRowsInSection:section];
}

- (IOSListTableViewCell *)tableView:(IOSListTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IOSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier];
    Position* position = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    cell.position = position;
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* headerTitle = [self.indexPathController.dataModel sectionNameForSection:section];
    if ([headerTitle isEqualToString:TLIndexPathDataModelNilSectionName]) {
        return nil;
    }
    return headerTitle;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Position* position = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
        [[DataService sharedInstance].managedObjectContext deleteObject:position];
    }
    
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - TableView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
