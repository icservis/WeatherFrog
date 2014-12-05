//
//  IOSDetailViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSDetailViewController.h"
#import "IOSMapViewController.h"
#import "IOSSplitViewController.h"

static NSTimeInterval const kContainerAnimationDuration = 0.25f;

@interface IOSDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *collectionContainerView;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) UIBarButtonItem* viewModeButtonItem;
@property (strong, nonatomic) UISegmentedControl* viewModeControl;
@property (strong, nonatomic) UITraitCollection* splitViewControllerTraitCollection;
@property (assign, nonatomic) NSInteger selectedContainerViewIndex;

@end

@implementation IOSDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionContainerView.alpha = 0.f;
    self.graphContainerView.alpha = 0.f;
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.splitViewControllerTraitCollection = self.splitViewController.traitCollection;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerWillTrasitionToTraitCollectionNotification:) name:KViewControllerWillTrasitionToTraitCollection object:nil];
    
    if (self.selectedPosition == nil) {
        Position* lastUpdatedBookmarkedPosition = [[DataService sharedInstance] lastUpdatedBookmarkedObject];
        if (lastUpdatedBookmarkedPosition) {
            self.selectedPosition = lastUpdatedBookmarkedPosition;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Setters and Getters

- (void)setSelectedPosition:(Position *)selectedPosition
{
    [super setSelectedPosition:selectedPosition];
    self.navigationItem.title = selectedPosition.name;
}

- (UIBarButtonItem*)viewModeButtonItem
{
    if (_viewModeButtonItem == nil) {
        _viewModeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.viewModeControl];
    }
    return _viewModeButtonItem;
}

- (UISegmentedControl*)viewModeControl
{
    if (_viewModeControl == nil) {
        NSArray* items = @[NSLocalizedString(@"Collection", nil),NSLocalizedString(@"Graph", nil)];
        _viewModeControl = [[UISegmentedControl alloc] initWithItems:items];
        _viewModeControl.selectedSegmentIndex = 0;
        [_viewModeControl addTarget:self action:@selector(viewModeControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _viewModeControl;
}

- (void)setSplitViewControllerTraitCollection:(UITraitCollection *)splitViewControllerTraitCollection
{
    if (_splitViewControllerTraitCollection != splitViewControllerTraitCollection) {
        
        UIUserInterfaceSizeClass splitViewControllerHorizontalClass = [splitViewControllerTraitCollection horizontalSizeClass];
        UIUserInterfaceSizeClass splitViewControllerVerticalClass = [splitViewControllerTraitCollection verticalSizeClass];
        
        if (splitViewControllerVerticalClass == UIUserInterfaceSizeClassRegular && splitViewControllerHorizontalClass == UIUserInterfaceSizeClassRegular) {
            
            if (self.splitViewController.displayModeButtonItem) {
                self.navigationItem.leftBarButtonItems = @[self.splitViewController.displayModeButtonItem, self.viewModeButtonItem];
            } else {
                self.navigationItem.leftBarButtonItems = @[self.viewModeButtonItem];
            }
            
            self.selectedContainerViewIndex = self.viewModeControl.selectedSegmentIndex;
            
        } else {
            
            if (self.splitViewController.displayModeButtonItem) {
                self.navigationItem.leftBarButtonItems = @[self.splitViewController.displayModeButtonItem];
            } else {
                self.navigationItem.leftBarButtonItems = nil;
            }
            
            if (splitViewControllerVerticalClass == UIUserInterfaceSizeClassCompact) {
                self.selectedContainerViewIndex = 1;
            } else {
                self.selectedContainerViewIndex = 0;
            }
        }
        
        _splitViewControllerTraitCollection = splitViewControllerTraitCollection;
    }
}

- (void)setSelectedContainerViewIndex:(NSInteger)selectedContainerViewIndex
{
    _selectedContainerViewIndex = selectedContainerViewIndex;
    
    [UIView animateWithDuration:kContainerAnimationDuration animations:^{
        if (selectedContainerViewIndex == 1) {
            self.graphContainerView.alpha = 1.f;
            self.collectionContainerView.alpha = 0.f;
        } else {
            self.graphContainerView.alpha = 0.f;
            self.collectionContainerView.alpha = 1.f;
        }
    }];
}

#pragma mark - Notifications

- (void)viewControllerWillTrasitionToTraitCollectionNotification:(NSNotification*)notification
{
    UITraitCollection* splitViewControllerTraitCollection = (UITraitCollection*)notification.object;
    self.splitViewControllerTraitCollection = splitViewControllerTraitCollection;
}

#pragma mark - User Actions

- (IBAction)viewModeControlValueChanged:(id)sender
{
    self.selectedContainerViewIndex = self.viewModeControl.selectedSegmentIndex;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"PresentMap"]) {
        IOSMapViewController* mapViewController = (IOSMapViewController*)segue.destinationViewController;
        mapViewController.delegate = self;
        mapViewController.selectedPosition = self.selectedPosition;
        mapViewController.closeBlock = ^() {
            [self dismissViewControllerAnimated:YES completion:^{
                DDLogVerbose(@"Controller closed");
            }];
        };
    }
}


@end
