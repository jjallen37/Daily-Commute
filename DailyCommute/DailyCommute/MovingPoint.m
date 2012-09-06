//
//  MovingPoint.m
//  DailyCommute
//
//  Created by James Allen on 3/26/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "MovingPoint.h"
#import "Route.h"


@implementation MovingPoint

@dynamic speed;
@dynamic latitude;
@dynamic longitude;
@dynamic time;
@dynamic route;

-(void)setLocation:(CLLocation *)location{
    self.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    self.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    self.speed = [NSNumber numberWithDouble:location.speed];
}

-(CLLocation *)location{
    return [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue 
                                      longitude:self.longitude.doubleValue];
 
}
@end
