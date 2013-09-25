//
//  Location.h
//  WeatherFrog
//
//  Created by Libor Kučera on 25.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Forecast;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * isMarked;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CLPlacemark * placemark;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSTimeZone * timezone;
@property (nonatomic, retain) NSOrderedSet *forecast;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)insertObject:(Forecast *)value inForecastAtIndex:(NSUInteger)idx;
- (void)removeObjectFromForecastAtIndex:(NSUInteger)idx;
- (void)insertForecast:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeForecastAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInForecastAtIndex:(NSUInteger)idx withObject:(Forecast *)value;
- (void)replaceForecastAtIndexes:(NSIndexSet *)indexes withForecast:(NSArray *)values;
- (void)addForecastObject:(Forecast *)value;
- (void)removeForecastObject:(Forecast *)value;
- (void)addForecast:(NSOrderedSet *)values;
- (void)removeForecast:(NSOrderedSet *)values;
@end
