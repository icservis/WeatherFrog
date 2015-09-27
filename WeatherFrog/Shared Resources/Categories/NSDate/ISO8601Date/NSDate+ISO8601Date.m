//
//  NSDate+ISO8601Date.m
//  Leyter Mobile
//
//  Created by Libor Kučera on 03.02.13.
//  Copyright (c) 2013 IC Servis, s.r.o. All rights reserved.
//

#import "NSDate+ISO8601Date.h"
#import "ISO8601DateFormatter.h"

@implementation NSDate (ISO8601Date)

+ (NSDateFormatter*)stringDateFormatter
{
    static NSDateFormatter* formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return formatter;
}

+ (NSDateFormatter*)stringShortDateFormatter
{
    static NSDateFormatter* formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return formatter;
}

+ (NSDateFormatter*)stringISODateFormatter
{
    static NSDateFormatter* formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return formatter;
}

+ (NSDateFormatter*)stringISODateAltFormatter
{
    static NSDateFormatter* formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return formatter;
}

+(NSDate*)dateWithString:(NSString*)string
{
    return [[NSDate stringDateFormatter] dateFromString:string];
}

+(NSDate*)dateWithShortString:(NSString*)string
{
    return [[NSDate stringShortDateFormatter] dateFromString:string];
}

+(NSDate*)isoDateWithString:(NSString*)string
{
    return [[NSDate stringISODateFormatter] dateFromString:string];
}

+(NSDate*)isoDateAltWithString:(NSString*)string
{
    return [[NSDate stringISODateAltFormatter] dateFromString:string];
}

@end
