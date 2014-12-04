//
//  MapGestureRecogniser.m
//  WeatherFrog
//
//  Created by Libor Kučera on 03.12.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import "MapGestureRecogniser.h"


@implementation MapGestureRecogniser

- (id)initWithTarget:(id)target action:(SEL)action
{
    if (self = [super initWithTarget:target action:action]) {
        [self configure];
    }
    return self;
}

- (void)configure
{
#if TARGET_OS_IPHONE
    self.minimumPressDuration = 1.2;
#elif TARGET_OS_MAC
    self.numberOfClicksRequired = 1;
#endif
}

@end
