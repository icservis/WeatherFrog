//
//  DetailViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 18.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "DetailViewController.h"
#import "Weather.h"
#import "CFGUnitConverter.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDateFormatter* localDateFormatter;
@property (nonatomic, strong) CFGUnitConverter* unitsConverter;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* closeButon;
@property (nonatomic, weak) IBOutlet UITableView* tableView;

- (IBAction)closeButonTapped:(id)sender;

@end

@implementation DetailViewController

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
    
    [self.localDateFormatter setTimeZone:self.timezone];
    [self.localDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.localDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    self.title = [self.localDateFormatter stringFromDate:self.weather.timestamp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButonTapped:(id)sender
{
    if (self.completionBlock != nil) {
        self.completionBlock(YES);
    }
}

- (NSDateFormatter*)localDateFormatter
{
    if (_localDateFormatter == nil) {
        _localDateFormatter = [[NSDateFormatter alloc] init];
    }
    return _localDateFormatter;
}

- (CFGUnitConverter*)unitsConverter
{
    if (_unitsConverter == nil) {
        _unitsConverter = [[CFGUnitConverter alloc] init];
    }
    return _unitsConverter;
}

#pragma mark - Notifications

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    [self.tableView reloadData];
}

#pragma mark - UITableViewdataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* DetailCellIdentifier = @"DetailCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DetailCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Temperature", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertTemperature:self.weather.temperature];
    }
    
    if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Wind direction", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertWindDirection:self.weather.windDirection];
    }
    
    if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Wind speed", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertWindSpeed:self.weather.windSpeed];
    }
    
    if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Wind scale", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertWindScale:self.weather.windScale];
    }
    
    if (indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"Precipitation", nil);
        
        NSNumber* precipitation;
        NSInteger hours = 0;
        if (self.weather.precipitation1h != nil) {
            precipitation = self.weather.precipitation1h;
            hours = 1;
        } else if (self.weather.precipitation2h != nil) {
            precipitation = self.weather.precipitation2h;
            hours = 2;
        } else if (self.weather.precipitation3h != nil) {
            precipitation = self.weather.precipitation3h;
            hours = 3;
        } else if (self.weather.precipitation6h != nil) {
            precipitation = self.weather.precipitation6h;
            hours = 6;
        }
        
        cell.detailTextLabel.text = [self.unitsConverter convertPrecipitation:precipitation period:hours];
    }
    
    if (indexPath.row == 5) {
        cell.textLabel.text = NSLocalizedString(@"Pressure", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertPressure:self.weather.pressure];
    }
    
    if (indexPath.row == 6) {
        cell.textLabel.text = NSLocalizedString(@"Humidity", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertPercent:self.weather.humidity];
    }
    
    if (indexPath.row == 7) {
        cell.textLabel.text = NSLocalizedString(@"Fog", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertPercent:self.weather.fog];
    }
    
    if (indexPath.row == 8) {
        cell.textLabel.text = NSLocalizedString(@"Cloudness", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertPercent:self.weather.cloudiness];
    }
    
    if (indexPath.row == 9) {
        cell.textLabel.text = NSLocalizedString(@"Low clouds", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertPercent:self.weather.lowClouds];
    }
    
    if (indexPath.row == 10) {
        cell.textLabel.text = NSLocalizedString(@"Medium clouds", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertPercent:self.weather.mediumClouds];
    }
    
    if (indexPath.row == 11) {
        cell.textLabel.text = NSLocalizedString(@"High clouds", nil);
        cell.detailTextLabel.text = [self.unitsConverter convertPercent:self.weather.highClouds];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 21.0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    [self.localDateFormatter setTimeZone:self.timezone];
    [self.localDateFormatter setDateFormat:@"zzzz"];
    return  [self.localDateFormatter stringFromDate:self.weather.timestamp];
}

@end
