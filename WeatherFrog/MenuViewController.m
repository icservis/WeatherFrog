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
    
    self.applicationNameLabel.text = NSLocalizedString(@"WeatherFrog 2", nil);
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    _selectedPlacemark = nil;
}

#pragma mark - setters and getters

- (LocationManager*)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [LocationManager sharedManager];
    }
    return _locationManager;
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext == nil) {
        AppDelegate* appDelegate = [self appDelegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSFetchedResultsController*)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate* findPredicate = [NSPredicate predicateWithValue:YES];
        [fetchRequest setPredicate:findPredicate];
        
        NSSortDescriptor* isMarkedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isMarked" ascending:NO];
        NSSortDescriptor* timestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray* sortDescriptors = [NSArray arrayWithObjects:isMarkedDescriptor, timestampDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"isMarked" cacheName:ForecastCache];
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
            UIViewController* frontViewController = [[(UINavigationController*)dvc viewControllers] firstObject];
            [nc setViewControllers: @[ frontViewController ] animated: YES];
            [rvc setFrontViewPosition: FrontViewPositionLeft animated: YES];
            
            if ([segue.identifier isEqualToString:@"showLocator"]) {
                LocatorViewController* locatorViewController = (LocatorViewController*)frontViewController;
                locatorViewController.selectedPlacemark = self.selectedPlacemark;
            }
            
            if ([segue.identifier isEqualToString:@"showForecast"]) {
                ForecastViewController* forecastViewController = (ForecastViewController*)frontViewController;
                if ([sender isKindOfClass:[UIButton class]]) {
                    // sender is ForecastButton = automatic update
                    Forecast* currentForecast = [[self appDelegate] currentForecast];
                    forecastViewController.useSelectedLocationInsteadCurrenLocation = NO;
                    forecastViewController.selectedForecast = currentForecast;
                } else {
                    // other sender
                    forecastViewController.useSelectedLocationInsteadCurrenLocation = YES;
                    forecastViewController.selectedPlacemark = self.selectedPlacemark;
                }
            }
        };
    }
    
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController* settingsNavController = segue.destinationViewController;
        SettingsViewController* settingsViewController = [[settingsNavController viewControllers] objectAtIndex:0];
        settingsViewController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showAbout"]) {
        UINavigationController* aboutNavController = segue.destinationViewController;
        AboutTableViewController* aboutTableViewController = [[aboutNavController viewControllers] objectAtIndex:0];
        aboutTableViewController.delegate = self;
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
    [self updateTable];
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
    
    NSNumber* latitude = [NSNumber numberWithDouble:_selectedPlacemark.location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:_selectedPlacemark.location.coordinate.longitude];
    
    if ([cell.location.latitude isEqualToNumber:latitude] || [cell.location.longitude isEqualToNumber:longitude]) {
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
    
    
    // FrontViewControler revealed
    if (self.revealViewController.frontViewPosition == FrontViewPositionRight) {
        
        DDLogVerbose(@"FrontViewPositionRight");
        [self forecastButtonTapped:self.forecastButton];
        
    } else {
        
        Forecast* currentForecast = [[self appDelegate] currentForecast];
        
        UINavigationController* frontNavigationController = (UINavigationController*)self.revealViewController.frontViewController;
        UIViewController* frontViewController = [[frontNavigationController viewControllers] firstObject];
        DDLogVerbose(@"frontViewController: %@", [frontViewController description]);
        [frontViewController becomeFirstResponder];
        
        if ([frontViewController isKindOfClass:[ForecastViewController class]]) {
            DDLogVerbose(@"ForecastViewController");
            ForecastViewController* forecastViewController = (ForecastViewController*)frontViewController;
            forecastViewController.useSelectedLocationInsteadCurrenLocation = NO;
            forecastViewController.selectedForecast = currentForecast;
        }
        
        if ([frontViewController isKindOfClass:[LocatorViewController class]]) {
            DDLogVerbose(@"LocationViewController");
            [self forecastButtonTapped:self.forecastButton];
        }
    
    }

}

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    
    // table
    [self updateTable];
    //buttons
    [self.forecastButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.locatorButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    // labels
    [self.applicationNameLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.applicationVersionLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]];
}

- (void)resignActive:(NSNotification*)notification
{
    DDLogInfo(@"resignActive");
    
    if (self.presentedViewController != nil && ![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{
            DDLogVerbose(@"dismissed");
        }];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AboutTableViewControllerDelegate

- (void)closeAboutTableViewController:(UITableViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
