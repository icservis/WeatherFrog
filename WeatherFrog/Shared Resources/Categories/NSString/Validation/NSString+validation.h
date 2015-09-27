//
//  NSString+validation.h
//  Ceny na dne SK
//
//  Created by Libor Kučera on 23.07.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (validation)

- (BOOL) isValidEmail;
- (BOOL) isValidName;
- (BOOL) isValidCount;
- (BOOL) isValidPassword;

@end
