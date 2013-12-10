//
//  SettingsSliderViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 02.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "SettingsSliderViewController.h"
#import "WeatherSymbol.h"

@interface SettingsSliderViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (nonatomic, weak) IBOutlet UISlider* notificationsSlider;
@property (nonatomic, weak) IBOutlet UILabel* notificationsLabel;
@property (nonatomic, weak) IBOutlet UILabel* notificationsTitle;
@property (weak, nonatomic) IBOutlet UITextView *notificationsTextView;

- (IBAction)sliderValueChanged:(id)sender;

@end

@implementation SettingsSliderViewController

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
    self.notificationsTitle.text = NSLocalizedString(@"Notification thrown when following conditions met:", nil);
    self.notificationsSlider.minimumValue = [self.minValue integerValue];
    self.notificationsSlider.maximumValue = [self.maxValue integerValue];
    self.notificationsSlider.value = [self.value integerValue];
    [self updateLevels];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    [self.notificationsLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.notificationsTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    [self.notificationsTextView setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
}

#pragma mark - IBActions

- (IBAction)sliderValueChanged:(id)sender
{
    int sliderValue = (int)roundf(self.notificationsSlider.value);
    NSNumber* value = [NSNumber numberWithInt:sliderValue];
    self.value = value;
    [self.notificationsSlider setValue:sliderValue animated:YES];
    [self updateLevels];
    
    [self.delegate settingsSliderController:self didUpdatedSlider:DefaultsNotifications value:value];
}

- (void)updateLevels
{
    self.notificationsLabel.text = [[UserDefaultsManager sharedDefaults] titleOfSliderValue:self.value forKey:DefaultsNotifications];
    self.notificationsTextView.text = [[UserDefaultsManager sharedDefaults] descriptionOfSliderValue:self.value forKey:DefaultsNotifications];
    
    NSUInteger notificalitionLevel = [self.value integerValue];
    NSArray* imageIndexes = [WeatherSymbol sampleSymbolsForNotificationLevel:notificalitionLevel];
    
    NSNumber* symbol;
    WeatherSymbol* weatherSymbol;
    if (imageIndexes[0] != nil) {
        symbol = imageIndexes[0];
        weatherSymbol = [[WeatherSymbol alloc] initWithSymbol:[symbol integerValue]];
        self.leftImageView.image = [weatherSymbol imageForSize:80 isNight:NO];
    }
    if (imageIndexes[1] != nil) {
        symbol = imageIndexes[1];
        weatherSymbol = [[WeatherSymbol alloc] initWithSymbol:[symbol integerValue]];
        self.centerImageView.image = [weatherSymbol imageForSize:80 isNight:NO];
    }
    if (imageIndexes[2] != nil) {
        symbol = imageIndexes[2];
        weatherSymbol = [[WeatherSymbol alloc] initWithSymbol:[symbol integerValue]];
        self.rightImageView.image = [weatherSymbol imageForSize:80 isNight:NO];
    }
}


@end
