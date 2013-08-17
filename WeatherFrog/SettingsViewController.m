//
//  SettingsViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "FbUserCell.h"

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* closeButon;

- (IBAction)closeButonTapped:(id)sender;

@end

@implementation SettingsViewController

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

    self.clearsSelectionOnViewWillAppear = NO;
    self.title = NSLocalizedString(@"Settings", nil);
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionStateOpened:) name:FbSessionOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionStateClosed:) name:FbSessionClosedNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - shared objects

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - IBActions

- (IBAction)closeButonTapped:(id)sender
{
    [self.delegate closeSettingsViewController:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 6;
    } else if (section == 3) {
        return 2;
    } else if (section == 4) {
        return 1;
    } else if (section == 5) {
        return 2;
    } else if (section == 6) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *FbUserCellIdentifier = @"FbUserCell";
    
    if (indexPath.section == 0) {
        
        FbUserCell* cell = (FbUserCell*)[tableView dequeueReusableCellWithIdentifier:FbUserCellIdentifier forIndexPath:indexPath];
        cell.fbUser = [[self appDelegate] fbUser];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        
        return cell;
        
    } else {
        
        UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Fetch Forecast in Background", nil);
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Share Location and Forecast", nil);
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
        } else if (indexPath.section == 2) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"PortraitView", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Background Images", nil);
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Select Background", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"Background Rotation", nil);
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else if (indexPath.row == 4) {
                cell.textLabel.text = NSLocalizedString(@"Sound Effects", nil);
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else if (indexPath.row == 5) {
                cell.textLabel.text = NSLocalizedString(@"On Screen Help", nil);
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
        } else if (indexPath.section == 3) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Accuracy", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Timeout", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
        } else if (indexPath.section == 4) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Pan & Zoom", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
        } else if (indexPath.section == 5) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Accuracy", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Validity", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
        } else if (indexPath.section == 6) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Temperature", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Wind Speed", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Precipitation", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"Pressure", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 4) {
                cell.textLabel.text = NSLocalizedString(@"Altitude", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        return cell;
    }
    
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return NSLocalizedString(@"Features", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Application Options", nil);
    } else if (section == 3) {
        return NSLocalizedString(@"Location Geocoder", nil);
    } else if (section == 4) {
        return NSLocalizedString(@"Map Engine", nil);
    } else if (section == 5) {
        return NSLocalizedString(@"Forecast Precision", nil);
    } else if (section == 6) {
        return NSLocalizedString(@"Forecast Units", nil);
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 64.0f;
    } else {
        return  44.0f;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        NSDictionary<FBGraphUser> * fbUser = [[self appDelegate] fbUser];
        if (fbUser == nil) {
            [[self appDelegate] openSession];
        } else {
            [[self appDelegate] closeSession];
        }
        
    }
}

#pragma mark - NSnotification

- (void)fbSessionStateOpened:(NSNotification*)notification
{
    [self.tableView reloadData];
}

- (void)fbSessionStateClosed:(NSNotification*)notification
{
    [self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
