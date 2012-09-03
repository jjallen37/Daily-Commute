//
//  Commute.h
//  Daily-Commute
//
//  Created by James Allen on 9/1/12.
//  Copyright (c) 2012 James Allen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//To be used with NSUSerDefaults to select the active commute.
#define kCurrentCommuteKey @"CurrentComute"

@class Route;

@interface Commute : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * arrivalTime;
@property (nonatomic, retain) NSSet *routes;
@end

@interface Commute (CoreDataGeneratedAccessors)

- (void)addRoutesObject:(Route *)value;
- (void)removeRoutesObject:(Route *)value;
- (void)addRoutes:(NSSet *)values;
- (void)removeRoutes:(NSSet *)values;

@end
