//
//  MapGestureRecogniser.h
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#define GESTURERECOGNISER_CLASS UILongPressGestureRecognizer
#define GESTURERECOGNISERDELEGATE_CLASS UIGestureRecognizerDelegate
#elif TARGET_OS_MAC
#define GESTURERECOGNISER_CLASS NSPressGestureRecognizer
#define GESTURERECOGNISERDELEGATE_CLASS NSGestureRecognizerDelegate
#endif



@protocol MapGestureRecogniserDelegate <GESTURERECOGNISERDELEGATE_CLASS>

@end

@interface MapGestureRecogniser : GESTURERECOGNISER_CLASS


@end
