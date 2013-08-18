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

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    DDLogVerbose(@"coordinate: %.5f, %.5f", coordinate.latitude, coordinate.longitude);
    _coordinate = coordinate;
}

- (NSString*)formatTitle:(CLPlacemark*)placemark
{
    if (placemark.name == nil) {
        
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

@end
