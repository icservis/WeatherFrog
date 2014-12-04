//
//  DataService.h
//  WeatherFrog
//
//  Created by Libor Kučera on 19.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PositionManager.h"
#import "ForecastManager.h"

@interface DataService : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (DataService*)sharedInstance;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSFetchRequest*)fetchRequestForAllObjects;
- (void)deleteAllObjects;

@end
