//
//  SettingsSliderViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 02.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "SettingsSliderViewController.h"

@interface SettingsSliderViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* closeButton;
@property (nonatomic, weak) IBOutlet UISlider* notificationsSlider;
@property (nonatomic, weak) IBOutlet UILabel* notificationsLabel;

- (IBAction)closeButtonTapped:(id)sender;
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
    self.notificationsSlider.minimumValue = [self.minValue integerValue];
    self.notificationsSlider.maximumValue = [self.maxValue integerValue];
    self.notificationsSlider.value = [self.value integerValue];
    self.notificationsLabel.text = [[UserDefaultsManager sharedDefaults] titleOfSliderValue:self.value forKey:DefaultsNotifications];
    
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
}

#pragma mark - IBActions

- (IBAction)closeButtonTapped:(id)sender
{
    [self.delegate closeSettingsSliderViewController:self];
}

- (IBAction)sliderValueChanged:(id)sender
{
    int sliderValue = (int)roundf(self.notificationsSlider.value);
    NSNumber* value = [NSNumber numberWithInt:sliderValue];
    [self.notificationsSlider setValue:sliderValue animated:YES];
    
    self.notificationsLabel.text = [[UserDefaultsManager sharedDefaults] titleOfSliderValue:value forKey:DefaultsNotifications];
    
    [self.delegate settingsSliderController:self didUpdatedSlider:DefaultsNotifications value:value];
}


@end
