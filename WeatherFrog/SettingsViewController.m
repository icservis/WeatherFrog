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
    
    [[UserDefaultsManager sharedDefaults] dictionaryForKey:DefaultsDisplayMode];
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
        return 3;
    } else if (section == 3) {
        return 2;
    } else if (section == 4) {
        return 2;
    } else if (section == 5) {
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
        UserDefaultsManager* sharedDefaults = [UserDefaultsManager sharedDefaults];
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Fetch Forecast in Background", nil);
                cell.detailTextLabel.text = nil;
                if ([[UserDefaultsManager sharedDefaults] fetchForecastInBackground]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Share Location and Forecast", nil);
                cell.detailTextLabel.text = nil;
                if ([[UserDefaultsManager sharedDefaults] shareLocationAndForecast]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            
        } else if (indexPath.section == 2) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Display Mode", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults displayMode] forKey:DefaultsDisplayMode];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Sound Effects", nil);
                cell.detailTextLabel.text = nil;
                if ([[UserDefaultsManager sharedDefaults] soundEffects]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"On Screen Help", nil);
                cell.detailTextLabel.text = nil;
                if ([[UserDefaultsManager sharedDefaults] onScreenHelp]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            
        } else if (indexPath.section == 3) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Accuracy", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults locationGeocoderAccuracy] forKey:DefaultsLocationGeocoderAccuracy];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Timeout", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults locationGeocoderTimeout] forKey:DefaultsLocationGeocoderTimeout];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
        } else if (indexPath.section == 4) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Accuracy", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults forecastAccuracy] forKey:DefaultsForecastAccuracy];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Validity", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults forecastValidity] forKey:DefaultsForecastValidity];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
        } else if (indexPath.section == 5) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Temperature", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults forecastUnitTemperature] forKey:DefaultsForecastUnitTemperature];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Wind Speed", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults forecastUnitWindspeed] forKey:DefaultsForecastUnitWindspeed];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Precipitation", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults forecastUnitPrecipitation] forKey:DefaultsForecastUnitPrecipitation];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"Pressure", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults forecastUnitPressure] forKey:DefaultsForecastUnitPressure];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else if (indexPath.row == 4) {
                cell.textLabel.text = NSLocalizedString(@"Altitude", nil);
                cell.detailTextLabel.text = [sharedDefaults titleForValue:[sharedDefaults forecastUnitAltitude] forKey:DefaultsForecastUnitAltitude];
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
        return NSLocalizedString(@"Forecast Precision", nil);
    } else if (section == 5) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            // fetch in Background
            BOOL fetchForecastInBackground = [[UserDefaultsManager sharedDefaults] fetchForecastInBackground];
            [[UserDefaultsManager sharedDefaults] setFetchForecastInBackground:!fetchForecastInBackground];
        } else if (indexPath.row == 1) {
             // share location and Forecast
            BOOL shareLocationAndForecast = [[UserDefaultsManager sharedDefaults] shareLocationAndForecast];
            [[UserDefaultsManager sharedDefaults] setShareLocationAndForecast:!shareLocationAndForecast];
        }
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            // display mode
            [self performSegueWithIdentifier:@"showElement" sender:DefaultsDisplayMode];
        } else if (indexPath.row == 1) {
            //sound effects
            BOOL soundEffects = [[UserDefaultsManager sharedDefaults] soundEffects];
            [[UserDefaultsManager sharedDefaults] setSoundEffects:!soundEffects];
        } else if (indexPath.row == 2) {
            /// on screen help
            BOOL onScreenHelp = [[UserDefaultsManager sharedDefaults] onScreenHelp];
            [[UserDefaultsManager sharedDefaults] setOnScreenHelp:!onScreenHelp];
        }
        
    } else if (indexPath.section == 3) {
        
        if (indexPath.row == 0) {
            // geocoder accuracy
            [self performSegueWithIdentifier:@"showElement" sender:DefaultsLocationGeocoderAccuracy];
        } else if (indexPath.row == 1) {
            // deocoder timeout
            [self performSegueWithIdentifier:@"showElement" sender:DefaultsLocationGeocoderTimeout];
        }
        
    } else if (indexPath.section == 4) {
        
        if (indexPath.row == 0) {
            // forecast accuracy
            [self performSegueWithIdentifier:@"showElement" sender:DefaultsForecastAccuracy];
        } else if (indexPath.row == 1) {
            // forecast validity
            [self performSegueWithIdentifier:@"showElement" sender:DefaultsForecastValidity];
        }
        
    } else if (indexPath.section == 5) {
        
        if (indexPath.row == 0) {
            // forecast unit temperature
        } else if (indexPath.row == 1) {
            // forecast unit windspeed
        } else if (indexPath.row == 2) {
            // forecast unit precipitation
        } else if (indexPath.row == 3) {
            // forecast unit pressure
        } else if (indexPath.row == 4) {
            // forecast unit altitude
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showElement"]) {
        
        NSString* elementIdentifier = (NSString*)sender;
        SettingsElementViewController* settingsElementViewController = (SettingsElementViewController*)segue.destinationViewController;
        settingsElementViewController.delegate = self;
        settingsElementViewController.identifier = elementIdentifier;
        settingsElementViewController.title = [[UserDefaultsManager sharedDefaults] elementTitleForKey:elementIdentifier];
        settingsElementViewController.titles = [[UserDefaultsManager sharedDefaults] titlesForKey:elementIdentifier];
        settingsElementViewController.values = [[UserDefaultsManager sharedDefaults] valuesForKey:elementIdentifier];
        
        if ([elementIdentifier isEqualToString:DefaultsDisplayMode]) {
            settingsElementViewController.value = [[UserDefaultsManager sharedDefaults] displayMode];
        }
        
        if ([elementIdentifier isEqualToString:DefaultsLocationGeocoderAccuracy]) {
            settingsElementViewController.value = [[UserDefaultsManager sharedDefaults] locationGeocoderAccuracy];
        }
        
        if ([elementIdentifier isEqualToString:DefaultsLocationGeocoderTimeout]) {
            settingsElementViewController.value = [[UserDefaultsManager sharedDefaults] locationGeocoderTimeout];
        }
        
        if ([elementIdentifier isEqualToString:DefaultsForecastAccuracy]) {
            settingsElementViewController.value = [[UserDefaultsManager sharedDefaults] forecastAccuracy];
        }
        
        if ([elementIdentifier isEqualToString:DefaultsForecastValidity]) {
            settingsElementViewController.value = [[UserDefaultsManager sharedDefaults] forecastValidity];
        }
    }
}

#pragma mark - SettingsElementViewControllerDelegate

- (void)closeSettingsElementViewController:(UITableViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingsViewController:(UITableViewController *)controller didUpdatedElement:(NSString *)element value:(id)value
{
    if ([element isEqualToString:DefaultsDisplayMode]) {
        [[UserDefaultsManager sharedDefaults] setDisplayMode:value];
    }
    
    if ([element isEqualToString:DefaultsLocationGeocoderAccuracy]) {
        [[UserDefaultsManager sharedDefaults] setLocationGeocoderAccuracy:value];
    }
    
    if ([element isEqualToString:DefaultsLocationGeocoderTimeout]) {
        [[UserDefaultsManager sharedDefaults] setLocationGeocoderTimeout:value];
    }
    
    if ([element isEqualToString:DefaultsForecastAccuracy]) {
        [[UserDefaultsManager sharedDefaults] setForecastAccuracy:value];
    }
    
    if ([element isEqualToString:DefaultsForecastValidity]) {
        [[UserDefaultsManager sharedDefaults] setForecastValidity:value];
    }
    
    [self.tableView reloadData];
}

@end
