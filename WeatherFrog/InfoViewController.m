//
//  InfoViewController.m
//  WeatherFrog
//
//  Created by Libor Kučera on 13.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "AppDelegate.h"
#import "InfoViewController.h"

@interface InfoViewController ()

@property (nonatomic, weak) IBOutlet UITextView* textView;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation InfoViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.title = NSLocalizedString(@"Diagnostic Logs", nil);
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    DDFileLogger*fileLogger = [appDelegate fileLogger];
    id <DDLogFileManager> manager = [fileLogger logFileManager];
    NSString* logFilePath = [[manager sortedLogFilePaths] firstObject];
    //DDLogInfo(@"logFilePath: %@", logFilePath);
    
    NSError* error;
    NSString* logs = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:&error];
    NSArray* logsArray = [logs componentsSeparatedByString:@"\n"];
    NSArray* reversedLogsArray = [[logsArray reverseObjectEnumerator] allObjects];
    NSString* reversedLogs = [reversedLogsArray componentsJoinedByString:@"\n"];
    self.textView.text = reversedLogs;
    [self.textView scrollsToTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

- (IBAction)doneButtonTapped:(id)sender
{
    if (self.compleletonBlock != nil) {
        self.compleletonBlock(YES);
    }
}

#pragma mark - Notifications

- (void)preferredContentSizeChanged:(NSNotification*)notification
{
    DDLogInfo(@"preferredContentSizeChanged");
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
