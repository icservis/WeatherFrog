//
//  MapAnnotationButton.m
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "MapAnnotationButton.h"

@implementation MapAnnotationButton

+ (instancetype)annotationButtonWithTarget:(id)target action:(SEL)action type:(MapAnnotationButtonCalloutAccessoryViewType)type
{
#if TARGET_OS_IPHONE

    MapAnnotationButton* button;
    if (type == MapAnnotationButtonCalloutAccessoryViewTypeLeft) {
        button = [MapAnnotationButton buttonWithType:UIButtonTypeContactAdd];
    }
    if (type == MapAnnotationButtonCalloutAccessoryViewTypeRight) {
        button = [MapAnnotationButton buttonWithType:UIButtonTypeInfoLight];
    }
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
    
#elif TARGET_OS_MAC

    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 44, 44)];
    if (type == MapAnnotationButtonCalloutAccessoryViewTypeLeft) {
        [button setTitle: @"L"];
    }
    if (type == MapAnnotationButtonCalloutAccessoryViewTypeRight) {
        [button setTitle: @"R"];
    }
    
    [button setButtonType:NSMomentaryLightButton]; //Set what type button You want
    [button setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
    
    [button setTarget:target];
    [button setAction:action];
    
    return button;
    
#endif
    
}

@end
