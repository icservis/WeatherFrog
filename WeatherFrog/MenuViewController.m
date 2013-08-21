//
//  MenuViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "LocationCell.h"

@interface MenuViewController ()

@property (nonatomic, weak) IBOutlet UILabel* applicationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* applicationVersionLabel;
@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.applicationNameLabel.text = NSLocalizedString(@"WeatherFrog", nil);
#ifdef DEBUG
    self.applicationVersionLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Version", nil), [[self appDeleagte] appVersionBuild]];
#else
    self.applicationVersionLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Version", nil), [[self appDeleagte] appVersion]];
#endif
    
    //Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _locatorViewController = nil;
    _forecastViewController = nil;
    _currentPlacemark = nil;
    _selectedPlacemark = nil;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]]) {
        
        SWRevealViewControllerSegue* rvcs = (SWRevealViewControllerSegue*) segue;
        SWRevealViewController* rvc = self.revealViewController;
        
        rvcs.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* nc = (UINavigationController*)rvc.frontViewController;
            UIViewController* frontViewController = [[(UINavigationController*)dvc viewControllers] objectAtIndex:0];
            [nc setViewControllers: @[ frontViewController ] animated: YES];
            [rvc setFrontViewPosition: FrontViewPositionLeft animated: YES];
            
            if ([segue.identifier isEqualToString:@"showLocator"]) {
                LocatorViewController* locatorViewController = (LocatorViewController*)frontViewController;
                locatorViewController.selectedPlacemark = _selectedPlacemark;
                _locatorViewController = locatorViewController;
            }
            
            if ([segue.identifier isEqualToString:@"showForecast"]) {
                ForecastViewController* forecastViewController = (ForecastViewController*)frontViewController;
                forecastViewController.selectedPlacemark = _selectedPlacemark;
                _forecastViewController = forecastViewController;
            }
        };
    }
    
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController* settingsNavController = segue.destinationViewController;
        SettingsViewController* settingsViewController = [[settingsNavController viewControllers] objectAtIndex:0];
        settingsViewController.delegate = self;
    }
    
    
}

#pragma mark - Shared objects

- (AppDelegate*)appDeleagte
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}


#pragma mark - SettingsViewControllerDelegate

- (void)closeSettingsViewController:(UIViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        DDLogInfo(@"controller: %@", [controller description]);
    }];
}

#pragma mark - Setters and Getters

- (void)setSelectedPlacemark:(CLPlacemark *)selectedPlacemark
{
    DDLogInfo(@"selectedPlacemark: %@", [selectedPlacemark description]);
    _selectedPlacemark = selectedPlacemark;
    
}

#pragma mark - UITableViewdataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return  0;
    } else if (section == 2) {
        return  0;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *LocationCellIdentifier = @"LocationCell";
    
    if (indexPath.section == 0) {
        
        UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Locator", nil);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Current location", nil);
        }
        
        return cell;
        
    } else {
        LocationCell* cell = (LocationCell*)[tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return NSLocalizedString(@"Recent Places", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Saved Places", nil);
    }
    
    return 0;
}

#pragma mark - UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showLocator" sender:cell];
        } else if (indexPath.row ==1) {
            _selectedPlacemark = _currentPlacemark;
            [self performSegueWithIdentifier:@"showForecast" sender:cell];
        }
        
    }
}

#pragma mark - Notifications

- (void)locationManagerUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    DDLogInfo(@"notification: %@", [notification description]);
    NSDictionary* userInfo = notification.userInfo;
    CLPlacemark* currentPlacemark = [userInfo objectForKey:@"currentPlacemark"];
    _currentPlacemark = currentPlacemark;
}

@end
