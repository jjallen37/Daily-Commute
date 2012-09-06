//
//  ICB_WeatherConditions.m
//  DailyCommute
//
//  Created by Weston Catron on 4/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "ICB_WeatherConditions.h"

@implementation ICB_WeatherConditions

@synthesize currentTemp, condition, conditionImageURL, location, lowTemp, highTemp;

- (ICB_WeatherConditions *)initWithQuery:(NSString *)query
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

@end
