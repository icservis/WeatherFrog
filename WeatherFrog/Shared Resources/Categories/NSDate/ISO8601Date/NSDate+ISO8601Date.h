//
//  NSDate+ISO8601Date.h
//  Leyter Mobile
//
//  Created by Libor Kučera on 03.02.13.
//  Copyright (c) 2013 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISO8601Date)

+(NSDate*)dateWithString:(NSString*)string;
+(NSDate*)dateWithShortString:(NSString*)string;
+(NSDate*)isoDateWithString:(NSString*)string;
+(NSDate*)isoDateAltWithString:(NSString*)string;

@end
