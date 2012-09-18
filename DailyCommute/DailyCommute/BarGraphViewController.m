//
//  BarGraphController.m
//  CorePlot
//
//  Created by Harlan Haskins on 8/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "BarGraphViewController.h"
#import "Route.h"

@interface BarGraphViewController ()
@end

@implementation BarGraphViewController
CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPlot];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = YES;
    self.hostView.hostedGraph = graph;
    self.hostView.allowPinchScaling = YES;
    self.hostView.userInteractionEnabled = YES;
    self.timePlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:1.0f green:1.0f blue:1.0f alpha:1.0f] horizontalBars:NO];
    self.timePlot.barBasesVary = NO;
    self.delayPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:0.788f green:0.2f blue:0.0f alpha:1.0f] horizontalBars:NO];
    self.delayPlot.barBasesVary = YES;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    graph.paddingBottom = 95.0f;
    graph.paddingLeft   = 5.0f;
    graph.paddingTop    = 5.0f;
    graph.paddingRight  = 5.0f;
    graph.plotAreaFrame.paddingBottom = 40.0f;
    graph.plotAreaFrame.paddingTop    = 30.0f;
    graph.plotAreaFrame.paddingLeft   = 30.0f;
    // 3 - Set up styles
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Signika-Bold";
    titleStyle.fontSize = 16.0f;
    // 4 - Set up title
    graph.title = nil;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint {
    return YES;
}

-(void)configurePlots {
    // 1 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.5;
    // 2 - Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = @[self.delayPlot, self.timePlot];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        barX += CPDBarWidth;
    }
    // 5 - Set up plot space
    CGFloat xMax = [[[self fetchedResultsController] fetchedObjects] count];
    CGFloat yMin = 0.0f;
    CGFloat yMax = [[self longestDelay] floatValue];  // should determine dynamically based on max price
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMax - 6) length:CPTDecimalFromFloat(6.0f)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    [plotSpace scaleToFitPlots:[graph allPlots]];
}

-(void)configureAxes {
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Signika-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Signika-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.title = @"Date";
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromInt(5);
    int dateCount = [[self.fetchedResultsController fetchedObjects] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    for (Route* r in [self.fetchedResultsController fetchedObjects]) {
        CPTAxisLabel *label;
            if (dateCount < 5 || i % (dateCount / 5) == 0) {
                label = [[CPTAxisLabel alloc] initWithText:[self stringForRoute:r]  textStyle:axisSet.xAxis.labelTextStyle];
            }
            else {
                label = [[CPTAxisLabel alloc] initWithText:@""  textStyle:axisSet.xAxis.labelTextStyle];
            }
            CGFloat location = i++;
            label.tickLocation = CPTDecimalFromCGFloat(location);
            label.offset = axisSet.xAxis.majorTickLength;
            if (label) {
                [xLabels addObject:label];
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
    }
    axisSet.xAxis.axisLabels = xLabels;
    axisSet.xAxis.majorTickLocations = xLocations;
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 20.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.title = @"Time";
    axisSet.yAxis.tickDirection = CPTSignPositive;
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = -20.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    int highest = [[self longestDelay] intValue];
    for (NSInteger j = 1; j <= (highest * 1.5); j++) {
        if (j % (highest / 2) == 0) {
            NSString *labelText = [self timeFormatted:j];
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:axisSet.yAxis.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = axisSet.yAxis.majorTickLength + axisSet.yAxis.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    axisSet.yAxis.axisLabels = yLabels;
    axisSet.yAxis.majorTickLocations = yMajorLocations;
    axisSet.yAxis.minorTickLocations = yMinorLocations;
    
}

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[[self fetchedResultsController] fetchedObjects] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (fieldEnum == 0) {
        return [NSNumber numberWithUnsignedInt:index];
    }
    
    else if (fieldEnum == 1) {
        NSNumber *barSize = [self timeIntervalOfRoute:(Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:index]];
        if (barSize) {
            CPTBarPlot *p = (CPTBarPlot*) plot;
            NSNumber *delaySize = [self delayOfRoute:(Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:index]];
            if (p.barBasesVary) {
                if ([delaySize intValue] != -1) {
                    return @([barSize intValue] + [delaySize intValue]);
                }
            }
            else {
                return barSize;
            }
        }
    }
    return [NSNumber numberWithInt:0];
}

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
    NSLog(@"Pressed");
    RecieptViewController *rVC = [[RecieptViewController alloc] initWithRoute:(Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:index]];
    [self.navigationController pushViewController:rVC animated:YES];
}

@end
