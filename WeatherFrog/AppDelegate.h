//
//  AppDelegate.h
//  WeatherFrog
//
//  Created by Libor Kučera on 16.06.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const ReachabilityNotification = @"REACHABILITY_NOTIFICATION";
static NSString* const FbSessionOpenedNotification = @"FBSESSION_OPENED_NOTIFICATION";
static NSString* const FbSessionClosedNotification = @"FBSESSION_CLOSED_NOTIFICATION";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession* session;
@property (strong, nonatomic) NSDictionary<FBGraphUser>* fbUser;

- (BOOL)isInternetActive;
- (BOOL)isHostActive;
- (NSString*)localeCountryCode;
- (NSString*)localeLanguageCode;
- (void)openSession;
- (void)closeSession;

@end
