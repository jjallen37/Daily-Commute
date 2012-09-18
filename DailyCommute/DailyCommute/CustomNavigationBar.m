//
//  CustomNavigationBar.m
//  DailyCommute
//
//  Created by James Allen on 3/27/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed:@"NewNavBar.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}


@end
