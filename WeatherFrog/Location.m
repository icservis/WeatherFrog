//
//  Location.m
//  WeatherFrog
//
//  Created by Libor Kučera on 17.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic name;
@dynamic latitude;
@dynamic longitude;
@dynamic altitude;
@dynamic timestamp;
@dynamic placemark;
@dynamic timezone;

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title
{
    if ([self.name length] > 0) {
        return self.name;
    } else if ([self.placemark.name length] > 0) {
        return self.placemark.name;
    } else {
        return NSLocalizedString(@"No location", nil);
    }
}

- (NSString *)subtitle
{
    if (self.placemark != nil) {
        
        if ([self.placemark.ISOcountryCode isEqualToString:@"US"] || [self.placemark.ISOcountryCode isEqualToString:@"CA"] || [self.placemark.ISOcountryCode isEqualToString:@"GB"] || [self.placemark.ISOcountryCode isEqualToString:@"AU"]) {
            return [NSString stringWithFormat:@"%@ %@, %@",
                    self.placemark.postalCode,
                    self.placemark.locality,
                    self.placemark.administrativeArea];
        } else {
            return [NSString stringWithFormat:@"%@ %@, %@",
                    self.placemark.ISOcountryCode,
                    self.placemark.postalCode,
                    self.placemark.locality];
        }
        
    } else {
        return [NSString stringWithFormat:
                @"Lat: %.8f, Lng: %.8f",
                [self.latitude doubleValue],
                [self.longitude doubleValue]];
    }
}

@end
