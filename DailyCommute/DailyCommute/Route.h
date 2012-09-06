//
//  Route.h
//  DailyCommute
//
//  Created by James Allen on 3/11/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Commute, MovingPoint;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) Commute *fromCommute;
@property (nonatomic, retain) NSSet *movingPoints;
@property (nonatomic, retain) Commute *toCommute;
@end

@interface Route (CoreDataGeneratedAccessors)

- (void)addMovingPointsObject:(MovingPoint *)value;
- (void)removeMovingPointsObject:(MovingPoint *)value;
- (void)addMovingPoints:(NSSet *)values;
- (void)removeMovingPoints:(NSSet *)values;

@end
