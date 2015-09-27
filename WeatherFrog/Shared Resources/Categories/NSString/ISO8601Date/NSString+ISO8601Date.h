//
//  NSString+ISO8601Date.h
//  Leyter Mobile
//
//  Created by Libor Kučera on 01.12.12.
//  Copyright (c) 2012 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ISO8601Date)

+(NSString*)stringWithDate:(NSDate*)date;
+(NSString*)stringWithShortDate:(NSDate*)date;
+(NSString*)stringWithISODate:(NSDate*)date;
+(NSString*)stringWithISODateOnly:(NSDate*)date;

@end
