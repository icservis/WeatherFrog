//
//  NSString+URLEncoding.h
//  Ceny na dne SK
//
//  Created by Libor Kučera on 10.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
