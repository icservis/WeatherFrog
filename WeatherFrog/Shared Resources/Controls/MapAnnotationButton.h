//
//  MapAnnotationButton.h
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#define BUTTON_CLASS UIButton
#elif TARGET_OS_MAC
#define BUTTON_CLASS NSButton
#endif

typedef NS_ENUM(NSUInteger, MapAnnotationButtonCalloutAccessoryViewType) {
    MapAnnotationButtonCalloutAccessoryViewTypeLeft,
    MapAnnotationButtonCalloutAccessoryViewTypeRight
};

@interface MapAnnotationButton : BUTTON_CLASS

+ (instancetype)annotationButtonWithTarget:(id)target action:(SEL)action type:(MapAnnotationButtonCalloutAccessoryViewType)type;

@end
