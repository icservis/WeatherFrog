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

@interface IOSDetailViewController () <IOSMapViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *collectionContainerView;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;

@property (strong, nonatomic) UIBarButtonItem* viewModeButtonItem;
@property (strong, nonatomic) UISegmentedControl* viewModeControl;
@property (strong, nonatomic) UITraitCollection* splitViewControllerTraintCollection;
@property (assign, nonatomic) NSInteger selectedContainerViewIndex;

@end

@implementation IOSDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionContainerView.hidden = YES;
    self.graphContainerView.hidden = YES;
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.splitViewControllerTraintCollection = self.splitViewController.traitCollection;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerWillTrasitionToTraitCollectionNotification:) name:KViewControllerWillTrasitionToTraitCollection object:nil];
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

- (void)setSplitViewControllerTraintCollection:(UITraitCollection *)splitViewControllerTraintCollection
{
    if (_splitViewControllerTraintCollection != splitViewControllerTraintCollection) {
        
        UIUserInterfaceSizeClass splitViewControllerHorizontalClass = [splitViewControllerTraintCollection horizontalSizeClass];
        UIUserInterfaceSizeClass splitViewControllerVerticalClass = [splitViewControllerTraintCollection verticalSizeClass];
        
        if (splitViewControllerVerticalClass == UIUserInterfaceSizeClassRegular && splitViewControllerHorizontalClass == UIUserInterfaceSizeClassRegular) {
            
            self.navigationItem.leftBarButtonItems = @[self.splitViewController.displayModeButtonItem, self.viewModeButtonItem];
            self.selectedContainerViewIndex = self.viewModeControl.selectedSegmentIndex;
            
        } else {
            
            self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
            
            if (splitViewControllerVerticalClass == UIUserInterfaceSizeClassCompact) {
                self.selectedContainerViewIndex = 1;
            } else {
                self.selectedContainerViewIndex = 0;
            }
        }
        
        _splitViewControllerTraintCollection = splitViewControllerTraintCollection;
    }
}

- (void)setSelectedContainerViewIndex:(NSInteger)selectedContainerViewIndex
{
    _selectedContainerViewIndex = selectedContainerViewIndex;
    
    if (selectedContainerViewIndex == 1) {
        self.graphContainerView.hidden = NO;
        self.collectionContainerView.hidden = YES;
    } else {
        self.graphContainerView.hidden = YES;
        self.collectionContainerView.hidden = NO;
    }
}

#pragma mark - Notifications

- (void)viewControllerWillTrasitionToTraitCollectionNotification:(NSNotification*)notification
{
    UITraitCollection* splitViewControllerTraitCollection = (UITraitCollection*)notification.object;
    self.splitViewControllerTraintCollection = splitViewControllerTraitCollection;
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
    }
}

#pragma mark - MapViewControllerDeleagte

- (void)mapViewControllerDidClose:(IOSMapViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
