//
//  SettingsElementViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 01.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "SettingsMultiValueViewController.h"

@interface SettingsMultiValueViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* closeButton;

- (IBAction)closeButtonTapped:(id)sender;

@end

@implementation SettingsMultiValueViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)closeButtonTapped:(id)sender
{
    [self.delegate closeSettingsMultiValueViewController:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.titles[indexPath.row];
    id currentValue = self.values[indexPath.row];
    if ([currentValue isEqual:self.value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.value = self.values[indexPath.row];
    [self.tableView reloadData];
    
    [self.delegate settingsMultiValueViewController:self didUpdatedMultiValue:self.identifier value:self.value];
}

@end
