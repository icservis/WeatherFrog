//
//  IOSDetailViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "IOSDetailViewController.h"
#import "IOSMapViewController.h"

@interface IOSDetailViewController () <IOSMapViewControllerDelegate>

@end

@implementation IOSDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"PresentMapViewController"]) {
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
