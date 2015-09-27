//
//  NSString+validation.m
//  Ceny na dne SK
//
//  Created by Libor Kučera on 23.07.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "NSString+validation.h"

@implementation NSString (validation)

- (BOOL) isValidEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

- (BOOL) isValidName {
    
    return [self length] > 3;
}

- (BOOL) isValidCount {
    
    return  [self integerValue] > 0;
}

- (BOOL) isValidPassword
{
    return [self length ] > 3;
}

@end
