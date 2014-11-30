//
//  OSXFlippedView.m
//  WeatherFrog
//
//  Created by Libor Kučera on 30.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "OSXFlippedView.h"

@implementation OSXFlippedView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)isFlipped {
    return YES;
}

@end
