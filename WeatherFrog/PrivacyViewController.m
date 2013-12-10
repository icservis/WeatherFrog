//
//  PrivacyViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 10.12.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()

@property (nonatomic, weak) IBOutlet UITextView* textView;

@end

@implementation PrivacyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.title = NSLocalizedString(@"Privacy Policy", nil);
    [self loadPage];
}

- (void)loadPage
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"privacy_policy" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    self.textView.text = content;
}

#pragma mark - Notifications

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
