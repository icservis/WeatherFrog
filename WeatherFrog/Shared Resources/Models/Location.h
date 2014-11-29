//
//  Location.h
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * geoLatitude;
@property (nonatomic, retain) NSNumber * geoLongitude;
@property (nonatomic, retain) NSNumber * geoAltitude;
@property (nonatomic, retain) NSString * timezoneId;

@end
