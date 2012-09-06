//
//  ICB_WeatherConditions.h
//  DailyCommute
//
//  Created by Weston Catron on 4/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

@interface ICB_WeatherConditions : NSObject {
    NSString *condition, *location;
    NSURL *conditionImageURL;
    NSInteger currentTemp,lowTemp,highTemp;
}

@property (nonatomic,retain) NSString *condition, *location;
@property (nonatomic,retain) NSURL *conditionImageURL;
@property (nonatomic) NSInteger currentTemp, lowTemp, highTemp;

- (ICB_WeatherConditions *)initWithQuery:(NSString *)query;

@end
