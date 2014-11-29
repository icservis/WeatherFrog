//
//  ViewController.m
//  WeatherFrog for iOS
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSListViewController.h"
#import "IOSListTableViewCell.h"
#import "IOSDetailViewController.h"
#import "IOSSplitViewController.h"

@interface IOSListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentPositionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeAllBookmarksButton;

@property (strong, nonatomic) UIBarButtonItem *closeButtonItem;
@property (strong, nonatomic) UITraitCollection* splitViewControllerTraintCollection;

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
    self.splitViewControllerTraintCollection = self.splitViewController.traitCollection;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerWillTrasitionToTraitCollectionNotification:) name:KViewControllerWillTrasitionToTraitCollection object:nil];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        detailVC.data = sender;
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

- (void)setSplitViewControllerTraintCollection:(UITraitCollection *)splitViewControllerTraintCollection
{
    if (_splitViewControllerTraintCollection != splitViewControllerTraintCollection) {
        
        UIUserInterfaceSizeClass splitViewControllerHorizontalClass = [splitViewControllerTraintCollection horizontalSizeClass];
        //UIUserInterfaceSizeClass splitViewControllerVerticalClass = [splitViewControllerTraintCollection verticalSizeClass];
        
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
    self.splitViewControllerTraintCollection = splitViewControllerTraitCollection;
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
                                   DDLogVerbose(@"");
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

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IOSListTableViewCell* cell = (IOSListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ListCellIdentifier];
    
    cell.textLabel.text = @"Row";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
