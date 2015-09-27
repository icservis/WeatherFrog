//
//  NSString+URLEncoding.m
//  Ceny na dne SK
//
//  Created by Libor Kučera on 10.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "]];
}
@end
