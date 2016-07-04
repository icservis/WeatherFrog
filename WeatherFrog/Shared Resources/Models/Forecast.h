//
//  Forecast.h
//  
//
//  Created by Libor Kučera on 02.12.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Position;

@interface Forecast : NSManagedObject

@property (nonatomic, retain) NSNumber * forecastId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * validForDate;
@property (nonatomic, retain) Position *position;

@end
