//
//  Position.h
//  
//
//  Created by Libor Kučera on 02.12.14.
//
//

#import <Foundation/Foundation.h>

@class Forecast;

@interface Position : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * horizontalAccuracy;
@property (nonatomic, retain) NSNumber * verticalAccuracy;
@property (nonatomic, retain) NSNumber * isBookmark;
@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * timezoneId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSSet *forecasts;
@end

@interface Position (CoreDataGeneratedAccessors)

- (void)addForecastsObject:(Forecast *)value;
- (void)removeForecastsObject:(Forecast *)value;
- (void)addForecasts:(NSSet *)values;
- (void)removeForecasts:(NSSet *)values;

@end
