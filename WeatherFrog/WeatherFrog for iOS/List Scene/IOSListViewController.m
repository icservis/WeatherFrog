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

@interface IOSListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)addButtonTapped:(id)sender;

@end

@implementation IOSListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWilAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setEditing:NO animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setEditing:NO animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ReplaceDetail"]) {
        UINavigationController* navigationVC = segue.destinationViewController;
        IOSDetailViewController* detailVC = (IOSDetailViewController*)[[navigationVC viewControllers] firstObject];
        detailVC.data = sender;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [self.navigationController setToolbarHidden:!editing animated:animated];
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


- (IBAction)cancelButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"ReplaceDetail" sender:sender];
}

- (IBAction)addButtonTapped:(id)sender
{
    
}

@end
