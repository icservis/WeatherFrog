//
//  CLPlacemark+MKAnnotationDelegate.m
//  WeatherFrog
//
//  Created by Libor Kučera on 24.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "CLPlacemark+MKAnnotationDelegate.h"

@implementation CLPlacemark (MKAnnotationDelegate)

- (NSString*)title
{
    return self.name ?: self.location.description;
}

- (NSString*)subtitle
{
    NSString* address = [self.addressDictionary[@"FormattedAddressLines"] componentsJoinedByString:@", "];
    return ([address isEqualToString:self.title]) ? nil : address;
}

@end
