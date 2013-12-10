//
//  AboutTableViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 10.12.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AboutTableViewController.h"

@interface AboutTableViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem* doneButton;
@property (nonatomic, weak) IBOutlet UILabel* aboutLabel;
@property (nonatomic, weak) IBOutlet UILabel* supportLabel;
@property (nonatomic, weak) IBOutlet UILabel* disclaimerLabel;
@property (nonatomic, weak) IBOutlet UILabel* privacyLabel;
@property (nonatomic, weak) IBOutlet UILabel* logsLabel;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation AboutTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.title = NSLocalizedString(@"WeatherFrog App", nil);
    self.aboutLabel.text = NSLocalizedString(@"About (External Link)", nil);
    self.supportLabel.text = NSLocalizedString(@"Support (Email Message)", nil);
    self.disclaimerLabel.text = NSLocalizedString(@"Legal Disclaimer", nil);
    self.privacyLabel.text = NSLocalizedString(@"Privacy Policy", nil);
    self.logsLabel.text = NSLocalizedString(@"Diagnostic Logs", nil);
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self.delegate closeAboutTableViewController:self];
}

#pragma mark - Notifications

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    [self.tableView reloadData];
}

#pragma mark UItableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // URL in Browser
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weatherFrogSupportWeb]];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        // Open MessagesComposer
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        [mailVC setSubject:NSLocalizedString(@"Support Request", nil)];
        [mailVC setMailComposeDelegate:self];
        [mailVC.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
        NSArray* recepiets = [NSArray arrayWithObject:weatherFrogSupportEmail];
        [mailVC setToRecipients:recepiets];
        [self.navigationController presentViewController:mailVC animated:YES completion:^{
            
        }];
    }
}

#pragma mark - MFMailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    DDLogVerbose(@"result: %i", result);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (error != nil) {
            UIAlertView* mailAlerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mail Alert", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [mailAlerView show];
        }
    }];
}


@end
