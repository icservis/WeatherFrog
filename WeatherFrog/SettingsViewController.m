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
@property (nonatomic, strong) NSArray* elementsSections;

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
    self.elementsSections = [[UserDefaultsManager sharedDefaults] elementsSections];
        
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
    return self.elementsSections.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        NSDictionary* elementsSection = self.elementsSections[section-1];
        NSArray* elements = [elementsSection objectForKey:@"Elements"];
        return elements.count;
    }
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
        
        NSDictionary* elementsSection = self.elementsSections[indexPath.section-1];
        NSArray* elements = [elementsSection objectForKey:@"Elements"];
        NSDictionary* element = elements[indexPath.row];
        
        cell.textLabel.text = [element objectForKey:@"Title"];
        
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSToggleSwitchSpecifier"]) {
            
            BOOL value = NO;
            
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsFetchForecastInBackground]) {
                value = [sharedDefaults fetchForecastInBackground];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsShareLocationAndForecast]) {
                value = [sharedDefaults shareLocationAndForecast];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsSoundEffects]) {
                value = [sharedDefaults soundEffects];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsOnScreenHelp]) {
                value = [sharedDefaults onScreenHelp];
            }
            
            if (value == YES) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.detailTextLabel.text = nil;
        }
        
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSMultiValueSpecifier"]) {
            
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsDisplayMode]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults displayMode] forKey:DefaultsDisplayMode];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsLocationGeocoderAccuracy]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults locationGeocoderAccuracy] forKey:DefaultsLocationGeocoderAccuracy];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsLocationGeocoderTimeout]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults locationGeocoderTimeout] forKey:DefaultsLocationGeocoderTimeout];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsForecastAccuracy]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults forecastAccuracy] forKey:DefaultsForecastAccuracy];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsForecastValidity]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults forecastValidity] forKey:DefaultsForecastValidity];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsForecastUnitTemperature]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults forecastUnitTemperature] forKey:DefaultsForecastUnitTemperature];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsForecastUnitWindspeed]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults forecastUnitWindspeed] forKey:DefaultsForecastUnitWindspeed];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsForecastUnitPrecipitation]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults forecastUnitPrecipitation] forKey:DefaultsForecastUnitPrecipitation];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsForecastUnitPressure]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults forecastUnitPressure] forKey:DefaultsForecastUnitPressure];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsForecastUnitAltitude]) {
                cell.detailTextLabel.text = [sharedDefaults titleOfValue:[sharedDefaults forecastUnitAltitude] forKey:DefaultsForecastUnitAltitude];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
    
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return nil;
        
    } else {
        
        NSDictionary* elementsSection = self.elementsSections[section-1];
        return [elementsSection objectForKey:@"Title"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 64.0f;
        
    } else {
        
        return 44.0f;
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
    

    if (indexPath.section > 0) {
        
        UserDefaultsManager* sharedDefaults = [UserDefaultsManager sharedDefaults];
        
        NSDictionary* elementsSection = self.elementsSections[indexPath.section-1];
        NSArray* elements = [elementsSection objectForKey:@"Elements"];
        NSDictionary* element = elements[indexPath.row];
        
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSToggleSwitchSpecifier"]) {
            
            
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsFetchForecastInBackground]) {
                BOOL fetchForecastInBackground = [sharedDefaults fetchForecastInBackground];
                [[UserDefaultsManager sharedDefaults] setFetchForecastInBackground:!fetchForecastInBackground];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsShareLocationAndForecast]) {
                BOOL shareLocationAndForecast = [sharedDefaults shareLocationAndForecast];
                [[UserDefaultsManager sharedDefaults] setShareLocationAndForecast:!shareLocationAndForecast];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsSoundEffects]) {
                BOOL soundEffects = [sharedDefaults soundEffects];
                [[UserDefaultsManager sharedDefaults] setSoundEffects:!soundEffects];
            }
            if ([[element objectForKey:@"Key"] isEqualToString:DefaultsOnScreenHelp]) {
                BOOL onScreenHelp = [sharedDefaults onScreenHelp];
                [[UserDefaultsManager sharedDefaults] setOnScreenHelp:!onScreenHelp];
            }
        }
        
        if ([[element objectForKey:@"Type"] isEqualToString:@"PSMultiValueSpecifier"]) {
            
            [self performSegueWithIdentifier:@"showElement" sender:[element objectForKey:@"Key"]];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        settingsElementViewController.value = [[UserDefaultsManager sharedDefaults] elementValueForKey:elementIdentifier];
        settingsElementViewController.values = [[UserDefaultsManager sharedDefaults] valuesForKey:elementIdentifier];
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
