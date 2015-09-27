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

@interface IOSListViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

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

@dynamic tableView;

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.splitViewControllerTraitCollection = self.splitViewController.traitCollection;
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshContent) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerWillTrasitionToTraitCollectionNotification:) name:KViewControllerWillTrasitionToTraitCollection object:nil];
    
    [self refreshContent];
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

- (void)refreshContent
{
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    [self.refreshControl endRefreshing];
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

- (IBAction)bookmarkButtonTapped:(id)sender
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (IOSListTableViewCell *)tableView:(IOSListTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IOSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(IOSListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Position *position = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.position = position;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IOSListTableViewCell* cell = (IOSListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ReplaceDetail" sender:cell];
}

#pragma mark - Fetched results controller

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = [DataService sharedInstance].managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[DataService sharedInstance] fetchRequestForAllObjects];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(IOSListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}



@end
