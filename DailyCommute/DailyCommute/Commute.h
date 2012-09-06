//
//  Commute.h
//  DailyCommute
//
//  Created by James Allen on 3/19/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route;

#define kTravelMethodWalk @"Walk"
#define kTravelMethodBike @"Bike"
#define kTravelMethodDrive @"Drive"

//To be used with NSUSerDefaults to select the active commute.
#define kCurrentCommuteKey @"CurrentComute"


@interface Commute : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * travelMethod;
@property (nonatomic, retain) NSDate * toArrivalTime;
@property (nonatomic, retain) NSDate * fromArrivalTime;
@property (nonatomic, retain) NSSet *fromRoute;
@property (nonatomic, retain) NSSet *toRoute;
@end

@interface Commute (CoreDataGeneratedAccessors)

- (void)addFromRouteObject:(Route *)value;
- (void)removeFromRouteObject:(Route *)value;
- (void)addFromRoute:(NSSet *)values;
- (void)removeFromRoute:(NSSet *)values;

- (void)addToRouteObject:(Route *)value;
- (void)removeToRouteObject:(Route *)value;
- (void)addToRoute:(NSSet *)values;
- (void)removeToRoute:(NSSet *)values;

@end
