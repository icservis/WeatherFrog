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
    if (self.name == nil || [self.name length] == 0) {
        
        if (self.addressDictionary != nil) {
            NSArray* formattedAddress = [self.addressDictionary objectForKey:@"FormattedAddressLines"];
            if ([formattedAddress isKindOfClass:[NSArray class]]) {
                return formattedAddress[0];
            } else {
                return [self.addressDictionary objectForKey:@"SubLocality"];
            }
            
        } else {
            return [NSString stringWithFormat:@"@ %.5f, %.5f", self.location.coordinate.latitude, self.location.coordinate.longitude];
        }
        
    } else {
        return self.name;
    }
}

- (NSString*)subTitle
{
    return [NSString stringWithFormat:@"%@, %@", self.locality, self.country];
}

@end
