//
//  MapViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSMapViewController.h"

@interface IOSMapViewController () <UISearchBarDelegate>

@property (weak) IBOutlet UIToolbar *toolBar;
@property (weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, weak) IBOutlet UIBarButtonItem* cancelButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* bookmarkButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* forecastButton;

- (IBAction)closeButtonTapped:(id)sender;

@end

@implementation IOSMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self.delegate mapViewControllerDidClose:self];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

@end
