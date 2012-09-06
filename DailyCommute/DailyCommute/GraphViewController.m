//
//  GraphViewController.m
//  DailyCommute
//
//  Created by Weston Catron on 4/17/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()

@end

@implementation GraphViewController

@synthesize view;
@synthesize dataSource;

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

#pragma mark - GraphViewDataSource

-(NSInteger)numberOfLinesOnGraph:(GraphView *)graphView {
    return 0;
}

-(UIColor *)colorForLine:(NSInteger)lineNumber OnGraph:(GraphView *)graphView {
    return [UIColor clearColor];
}

-(NSInteger)numberOfPointsOnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    return 0;
}
-(NSInteger)valueForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    return 0;
}
-(NSDate *)dateForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    return [NSDate dateWithTimeIntervalSince1970:0];
}

-(NSInteger)greatestValueOnGraph:(GraphView *)graphView {
    return 0;
}

#pragma mark - other


@end
