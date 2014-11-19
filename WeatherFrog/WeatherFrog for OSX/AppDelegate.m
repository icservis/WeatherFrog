//
//  AppDelegate.m
//  WeatherFrog for OSX
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Logging.
    LumberjackFormatter *formatter = [[LumberjackFormatter alloc] init];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogDebug(@"applicationDirectory: %@", [[DataService sharedInstance] applicationDocumentsDirectory]);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[DataService sharedInstance] saveContext];
}

@end
