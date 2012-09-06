//
//  MovingPoint.h
//  DailyCommute
//
//  Created by James Allen on 3/26/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Route;

@interface MovingPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) Route *route;

-(void)setLocation:(CLLocation *)location;
-(CLLocation *)location;

@end
