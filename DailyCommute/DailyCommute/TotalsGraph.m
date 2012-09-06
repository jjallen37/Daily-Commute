//
//  TotalsGraph.m
//  DailyCommute
//
//  Created by Weston Catron on 4/17/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "TotalsGraph.h"

@interface TotalsGraph ()

@end

@implementation TotalsGraph

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSInteger)numberOfLinesOnGraph:(GraphView *)graphView {
    if ([[dataSource getToRoutes] count] > 0 && [[dataSource getFromRoutes] count] > 0) {
        return 2;
    }
    return 0;
}

-(UIColor *)colorForLine:(NSInteger)lineNumber OnGraph:(GraphView *)graphView {
    if (lineNumber == 0) {
        return [UIColor greenColor];
    }
    return [UIColor redColor];
}

-(NSInteger)numberOfPointsOnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    if (lineNumber == 0) {
        NSLog(@"Number of Points on Graph: %i",[[dataSource getToRoutes] count]);
        return [[dataSource getToRoutes] count];
    }
    NSLog(@"Number of Points on Graph: %i",[[dataSource getFromRoutes] count]);
    return [[dataSource getFromRoutes] count];
}
-(NSInteger)valueForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    if (lineNumber == 0) {
        return [[(Route *)[[dataSource getToRoutes] objectAtIndex:point] endTime] timeIntervalSinceDate:[(Route *)[[dataSource getToRoutes] objectAtIndex:point] startTime]];
    }
    return [[(Route *)[[dataSource getFromRoutes] objectAtIndex:point] endTime] timeIntervalSinceDate:[(Route *)[[dataSource getFromRoutes] objectAtIndex:point] startTime]];
}
-(NSDate *)dateForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    if (lineNumber == 0) {
        return [(Route *)[[dataSource getToRoutes] objectAtIndex:point] endTime];
    }
    return [(Route *)[[dataSource getFromRoutes] objectAtIndex:point] endTime];
}


-(NSInteger)greatestValueOnGraph:(GraphView *)graphView {
    int highestValue = 0;
    int comparisonValue = 0;
    
    for (Route *route in [dataSource getToRoutes]) {
        comparisonValue = [[route endTime] timeIntervalSinceDate:[route startTime]];
        if (comparisonValue > highestValue) {
            highestValue = comparisonValue;
        }
    }
    
    for (Route *route in [dataSource getFromRoutes]) {
        comparisonValue = [[route endTime] timeIntervalSinceDate:[route startTime]];
        if (comparisonValue > highestValue) {
            highestValue = comparisonValue;
        }
    }
    
    return highestValue*1.25;
}

@end
