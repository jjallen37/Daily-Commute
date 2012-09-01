//
//  Commute.h
//  Daily-Commute
//
//  Created by James Allen on 9/1/12.
//  Copyright (c) 2012 James Allen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MovingPoint;

@interface Commute : NSManagedObject

@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timeToArrive;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *movingPoints;
@end

@interface Commute (CoreDataGeneratedAccessors)

- (void)addMovingPointsObject:(MovingPoint *)value;
- (void)removeMovingPointsObject:(MovingPoint *)value;
- (void)addMovingPoints:(NSSet *)values;
- (void)removeMovingPoints:(NSSet *)values;

@end
