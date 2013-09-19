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
#import "Location+Store.h"

@interface MenuViewController ()

@property (nonatomic, weak) IBOutlet UILabel* applicationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* applicationVersionLabel;
@property (nonatomic, weak) IBOutlet UIButton* infoButton;
@property (nonatomic, weak) IBOutlet UIButton* settingsButton;
@property (nonatomic, weak) IBOutlet UIButton* locatorButton;
@property (nonatomic, weak) IBOutlet UIButton* forecastButton;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
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
    
    self.applicationNameLabel.text = NSLocalizedString(@"WeatherFrog", nil);
#ifdef DEBUG
    self.applicationVersionLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Version", nil), [[self appDelegate] appVersionBuild]];
#else
    self.applicationVersionLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Version", nil), [[self appDelegate] appVersion]];
#endif
    
    [self.locatorButton setTitle:NSLocalizedString(@"Locator", nil) forState:UIControlStateNormal];
    [self.forecastButton setTitle:NSLocalizedString(@"Current", nil) forState:UIControlStateNormal];
    
    // NSFetchedResultsController
    
    NSManagedObjectContext* currentContext = [NSManagedObjectContext contextForCurrentThread];
    NSPredicate* findPredicate = [NSPredicate predicateWithFormat:@"isMarked = 1 OR timestamp > %@", [NSDate dateWithTimeIntervalSinceNow:-3600]];
    NSFetchRequest* fetchRequest = [Location requestAllWithPredicate:findPredicate inContext:currentContext];
    NSSortDescriptor* isMarkedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isMarked" ascending:NO];
    NSSortDescriptor* timestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:isMarkedDescriptor, timestampDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController* fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:currentContext sectionNameKeyPath:@"isMarked" cacheName:@"Root"];
    fetchedResultController.delegate = self;
    
    self.fetchedResultsController = fetchedResultController;
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
        
        [self.tableView reloadData];
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

#pragma mark - Setters and Getters

- (void)setSelectedPlacemark:(CLPlacemark *)selectedPlacemark
{
    _selectedPlacemark = selectedPlacemark;
    [Location locationforPlacemark:_selectedPlacemark withTimezone:nil];
    [self performSegueWithIdentifier:@"showForecast" sender:nil];
}

#pragma mark - IBActions

- (IBAction)locatorButtonTapped:(id)sender
{
    DDLogVerbose(@"_selectedPlacemark: %@", [_selectedPlacemark description]);
    [self performSegueWithIdentifier:@"showLocator" sender:self];
}

- (IBAction)forecastButtonTapped:(id)sender
{
    [self updateCurrentPlacemark:NO];
    [self performSegueWithIdentifier:@"showForecast" sender:sender];
}

- (void)updateCurrentPlacemark:(BOOL)reloadData
{
    _selectedPlacemark = [[self appDelegate] currentPlacemark];
    [Location locationforPlacemark:_selectedPlacemark withTimezone:[NSTimeZone localTimeZone]];
    if (reloadData) {
        [self.tableView reloadData];
    }
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
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:[cell.location.latitude doubleValue] longitude:[cell.location.longitude doubleValue]];
    CLLocationDistance distance = [_selectedPlacemark.location distanceFromLocation:location];
    
    if (_selectedPlacemark != nil && distance < kCLLocationAccuracyHundredMeters) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
		[location deleteEntity];
    }
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Delete the row from the data source
        CLPlacemark* currentPlacemark = [[self appDelegate] currentPlacemark];
		[Location locationWithName:[currentPlacemark title] coordinate:currentPlacemark.location.coordinate altitude:currentPlacemark.location.altitude timezone:[NSTimeZone localTimeZone] placemark:currentPlacemark];
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
        DDLogInfo(@"controller: %@", [controller description]);
    }];
}

#pragma mark - InfoViewControllerDelegate

- (void)closeInfoViewController:(UIViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        DDLogInfo(@"controller: %@", [controller description]);
    }];
}

#pragma mark - LocationCellDelegate

- (void)reloadTableViewCell:(UITableViewCell *)cell
{
    LocationCell* locationCell = (LocationCell*)cell;
    NSIndexPath* indexpath = [self.tableView indexPathForCell:locationCell];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
