//
//  NSString+ISO8601Date.m
//  Leyter Mobile
//
//  Created by Libor Kučera on 01.12.12.
//  Copyright (c) 2012 IC Servis, s.r.o. All rights reserved.
//

#import "NSString+ISO8601Date.h"
#import "ISO8601DateFormatter.h"

@implementation NSString (ISO8601Date)

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

+ (NSDateFormatter*)stringISODateOnlyFormatter
{
    static NSDateFormatter* formatter = nil;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return formatter;
}

+(NSString*)stringWithDate:(NSDate*)date
{
    return [[NSString stringDateFormatter] stringFromDate:date];
}

+(NSString*)stringWithShortDate:(NSDate*)date
{
    return [[NSString stringShortDateFormatter] stringFromDate:date];
}

+(NSString*)stringWithISODate:(NSDate*)date
{
    return [[NSString stringISODateFormatter] stringFromDate:date];
}

+(NSString*)stringWithISODateOnly:(NSDate*)date
{
    return [[NSString stringISODateOnlyFormatter] stringFromDate:date];
}

@end
