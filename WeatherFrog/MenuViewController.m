//
//  MenuViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "Forecast.h"
#import "Location.h"
#import "LocationManager.h"

@interface MenuViewController ()

@property (nonatomic, weak) IBOutlet UILabel* applicationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* applicationVersionLabel;
@property (nonatomic, weak) IBOutlet UIButton* infoButton;
@property (nonatomic, weak) IBOutlet UIButton* settingsButton;
@property (nonatomic, weak) IBOutlet UIButton* locatorButton;
@property (nonatomic, weak) IBOutlet UIButton* forecastButton;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) LocationManager* locationManager;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

- (IBAction)locatorButtonTapped:(id)sender;
- (IBAction)forecastButtonTapped:(id)sender;

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
    
    self.revealViewController.delegate = self;
    
    self.applicationNameLabel.text = NSLocalizedString(@"WeatherFrog", nil);
#ifdef DEBUG
    self.applicationVersionLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Version", nil), [[self appDelegate] appVersionBuild]];
#else
    self.applicationVersionLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Version", nil), [[self appDelegate] appVersion]];
#endif
    
    [self.locatorButton setTitle:NSLocalizedString(@"Locator", nil) forState:UIControlStateNormal];
    [self.forecastButton setTitle:NSLocalizedString(@"Current", nil) forState:UIControlStateNormal];
    
    // NSFetchedResultsController
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerUpdate:) name:LocationManagerUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverseGeocoderUpdate:) name:ReverseGeocoderUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localNotificationReceived:) name:ApplicationReceivedLocalNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.selectedPlacemark = nil;
}

#pragma mark setters and getters

- (LocationManager*)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[LocationManager alloc] init];
    }
    return _locationManager;
}

- (NSFetchedResultsController*)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        
        AppDelegate* appDelegate = [self appDelegate];
        NSManagedObjectContext* currentContext = appDelegate.managedObjectContext;
        
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:currentContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate* findPredicate = [NSPredicate predicateWithValue:YES];
        [fetchRequest setPredicate:findPredicate];
        
        NSSortDescriptor* isMarkedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isMarked" ascending:NO];
        NSSortDescriptor* timestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray* sortDescriptors = [NSArray arrayWithObjects:isMarkedDescriptor, timestampDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:currentContext sectionNameKeyPath:@"isMarked" cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)setSelectedPlacemark:(CLPlacemark *)selectedPlacemark
{
    _selectedPlacemark = selectedPlacemark;
    [self performSegueWithIdentifier:@"showForecast" sender:nil];
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
            }
            
            if ([segue.identifier isEqualToString:@"showForecast"]) {
                ForecastViewController* forecastViewController = (ForecastViewController*)frontViewController;
                if ([sender isKindOfClass:[UIButton class]]) {
                    // sender is ForecastButton = automatic update
                    forecastViewController.useSelectedLocationInsteadCurrenLocation = NO;
                } else {
                    // other sender
                    forecastViewController.useSelectedLocationInsteadCurrenLocation = YES;
                }
                forecastViewController.selectedPlacemark = _selectedPlacemark;
            }
        };
    }
    
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController* settingsNavController = segue.destinationViewController;
        SettingsViewController* settingsViewController = [[settingsNavController viewControllers] objectAtIndex:0];
        settingsViewController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showInfo"]) {
        UINavigationController* infoNavController = segue.destinationViewController;
        InfoViewController* infoViewController = [[infoNavController viewControllers] objectAtIndex:0];
        infoViewController.delegate = self;
    }
}

#pragma mark - Shared objects

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - IBActions

- (IBAction)locatorButtonTapped:(id)sender
{
    DDLogVerbose(@"_selectedPlacemark: %@", [_selectedPlacemark description]);
    [self performSegueWithIdentifier:@"showLocator" sender:self];
}

- (IBAction)forecastButtonTapped:(id)sender
{
    CLPlacemark* currentPlacemark = [[self appDelegate] currentPlacemark];
    DDLogInfo(@"currentPlacemark: %@", [currentPlacemark description]);
    _selectedPlacemark = currentPlacemark;
    [self performSegueWithIdentifier:@"showForecast" sender:sender];
}

- (void)updatePlacemark:(CLPlacemark*)placemark
{
    DDLogInfo(@"updatePlacemark");
    _selectedPlacemark = placemark;
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:uiDelay];
}

- (void)updateTable
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewdataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* LocationCellIdentifier = @"LocationCell";
    
    LocationCell* cell = (LocationCell*)[tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
    cell.location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.delegate = self;
    
    CLLocationDistance distance = [_selectedPlacemark.location distanceFromLocation:cell.location.placemark.location];
    
    if (_selectedPlacemark != nil && distance == 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSString* sectionInfoName = sectionInfo.name;
    
    BOOL isMarked = [sectionInfoName boolValue];
    if (isMarked) {
        return NSLocalizedString(@"Stored locations", nil);
    } else {
        return NSLocalizedString(@"Last locations", nil);
    }
}

#pragma mark - UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Location* location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedPlacemark = location.placemark;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		Location* location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.locationManager deleteLocation:location];
    }
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Insert the row from the data source
        CLPlacemark* currentPlacemark = [[self appDelegate] currentPlacemark];
        [self.locationManager locationforPlacemark:currentPlacemark withTimezone:[NSTimeZone localTimeZone]];
    }
}

#pragma mark - Notifications

- (void)locationManagerUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
}

- (void)reverseGeocoderUpdate:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
}

- (void)localNotificationReceived:(NSNotification*)notification
{
    DDLogVerbose(@"notification: %@", [notification description]);
    
    if (self.presentedViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self forecastButtonTapped:self.forecastButton];
        }];
    } else {
        [self forecastButtonTapped:self.forecastButton];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - SettingsViewControllerDelegate

- (void)closeSettingsViewController:(UIViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        DDLogVerbose(@"controller: %@", [controller description]);
    }];
}

#pragma mark - InfoViewControllerDelegate

- (void)closeInfoViewController:(UIViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        DDLogVerbose(@"controller: %@", [controller description]);
    }];
}

#pragma mark - LocationCellDelegate

- (void)reloadTableViewCell:(UITableViewCell *)cell
{
    LocationCell* locationCell = (LocationCell*)cell;
    NSIndexPath* indexpath = [self.tableView indexPathForCell:locationCell];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - RevealViewControlelrDelegate

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    UINavigationController* nc = (UINavigationController*)revealController.frontViewController;
    UIViewController* frontViewController = [[nc viewControllers] objectAtIndex:0];
    DDLogVerbose(@"frontViewController: %@, position: %i", [frontViewController description], position);
    [frontViewController becomeFirstResponder];
    
    if ([frontViewController isKindOfClass:[ForecastViewController class]]) {
        ForecastViewController* forecastViewController = (ForecastViewController*)frontViewController;
        if (position == FrontViewPositionRight) {
            [forecastViewController setRevealMode:YES];
        } else {
            [forecastViewController setRevealMode:NO];
        }
    }
    if ([frontViewController isKindOfClass:[LocatorViewController class]]) {
        LocatorViewController* locatorViewController = (LocatorViewController*)frontViewController;
        if (position == FrontViewPositionRight) {
            [locatorViewController setRevealMode:YES];
        } else {
            [locatorViewController setRevealMode:NO];
        }
    }
}

@end
