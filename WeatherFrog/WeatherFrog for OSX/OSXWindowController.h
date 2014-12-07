//
//  WindowController.h
//  WeatherFrog
//
//  Created by Libor Kučera on 22.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OSXWindowController : NSWindowController

- (void)selectDetailSceneTabViewItemAccordingToViewModeControl;

@property (nonatomic, strong) NSString* toolBarTitle;

@end
