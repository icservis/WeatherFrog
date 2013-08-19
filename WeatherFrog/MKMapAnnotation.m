//
//  MKMapAnnotation.m
//  WeatherFrog
//
//  Created by Libor Kučera on 18.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "MKMapAnnotation.h"

@interface MKMapAnnotation ()

@property (nonatomic, readwrite, copy) NSString* title;
@property (nonatomic, readwrite, copy) NSString* subtitle;

@end

@implementation MKMapAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

#pragma mark - Placemark

- (id)initWithPlacemark:(CLPlacemark *)placemark
{
    if (self = [super init]) {
        self.coordinate = placemark.location.coordinate;
        self.title = [self formatTitle:placemark];
        self.subtitle = [self formatSubtitle:placemark];
    }
    return self;
}

- (void)updateWithPlacemark:(CLPlacemark*)placemark
{
    self.coordinate = placemark.location.coordinate;
    self.title = [self formatTitle:placemark];
    self.subtitle = [self formatSubtitle:placemark];
}


- (NSString*)formatTitle:(CLPlacemark*)placemark
{
    if (placemark.name == nil || [placemark.name length] == 0) {
        
        if (placemark.addressDictionary != nil) {
            NSArray* formattedAddress = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
            if ([formattedAddress isKindOfClass:[NSArray class]]) {
                return formattedAddress[0];
            } else {
                return [placemark.addressDictionary objectForKey:@"SubLocality"];
            }

        } else {
            return [NSString stringWithFormat:@"@ %.5f, %.5f", placemark.location.coordinate.latitude, placemark.location.coordinate.longitude];
        }
        
    } else {
        return placemark.name;
    }
}

- (NSString*)formatSubtitle:(CLPlacemark*)placemark
{
    return [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.country];
}

#pragma mark - Location

- (id)initWithLocation:(CLLocation *)location
{
    if (self = [super init]) {
        self.coordinate = location.coordinate;
        self.title = NSLocalizedString(@"Placemark", nil);
        self.subtitle = [NSString stringWithFormat:@"@ %.5f, %.5f", location.coordinate.latitude, location.coordinate.longitude];
    }
    return self;
}

- (void)updateWithLocation:(CLLocation *)location
{
    self.coordinate = location.coordinate;
    self.title = NSLocalizedString(@"Placemark", nil);
    self.subtitle = [NSString stringWithFormat:@"@ %.5f, %.5f", location.coordinate.latitude, location.coordinate.longitude];
}

@end
