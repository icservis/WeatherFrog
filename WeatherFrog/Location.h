//
//  Location.h
//  WeatherFrog
//
//  Created by Libor Kučera on 24.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CLPlacemark * placemark;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSTimeZone * timezone;
@property (nonatomic, retain) NSNumber * isMarked;

@end
