//
//  Forecast.h
//  WeatherFrog
//
//  Created by Libor Kučera on 21.08.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Astro, Weather;

@interface Forecast : NSManagedObject

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSDate * validTill;
@property (nonatomic, retain) CLPlacemark * placemark;
@property (nonatomic, retain) NSTimeZone * timezone;
@property (nonatomic, retain) NSOrderedSet *weather;
@property (nonatomic, retain) NSOrderedSet *astro;
@end

@interface Forecast (CoreDataGeneratedAccessors)

- (void)insertObject:(Weather *)value inWeatherAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWeatherAtIndex:(NSUInteger)idx;
- (void)insertWeather:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWeatherAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWeatherAtIndex:(NSUInteger)idx withObject:(Weather *)value;
- (void)replaceWeatherAtIndexes:(NSIndexSet *)indexes withWeather:(NSArray *)values;
- (void)addWeatherObject:(Weather *)value;
- (void)removeWeatherObject:(Weather *)value;
- (void)addWeather:(NSOrderedSet *)values;
- (void)removeWeather:(NSOrderedSet *)values;
- (void)insertObject:(Astro *)value inAstroAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAstroAtIndex:(NSUInteger)idx;
- (void)insertAstro:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAstroAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAstroAtIndex:(NSUInteger)idx withObject:(Astro *)value;
- (void)replaceAstroAtIndexes:(NSIndexSet *)indexes withAstro:(NSArray *)values;
- (void)addAstroObject:(Astro *)value;
- (void)removeAstroObject:(Astro *)value;
- (void)addAstro:(NSOrderedSet *)values;
- (void)removeAstro:(NSOrderedSet *)values;
@end
