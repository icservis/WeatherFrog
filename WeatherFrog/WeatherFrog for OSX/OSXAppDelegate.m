//
//  AppDelegate.m
//  WeatherFrog for OSX
//
//  Created by Libor Kučera on 18.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXAppDelegate.h"
#import "PositionManager.h"

@interface OSXAppDelegate ()

@end

@implementation OSXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // CrashLytics
    [Fabric with:@[[Crashlytics class]]];
    
    // Logging.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogDebug(@"applicationDirectory: %@", [[DataService sharedInstance] applicationDocumentsDirectory]);
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[DataService sharedInstance] saveContext];
}

@end
