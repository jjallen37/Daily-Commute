//
//  ScatterPlotViewController.m
//  CorePlot
//
//  Created by Harlan Haskins on 8/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "CommuteTimeScatterPlotViewController.h"
#import "RecieptViewController.h"
#import "Route.h"

@interface CommuteTimeScatterPlotViewController ()

@end

@implementation CommuteTimeScatterPlotViewController

#pragma mark - UIViewController lifecycle methods
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    graph.title = nil;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Signika-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    graph.paddingBottom = 5.0f;
    graph.paddingLeft   = 5.0f;
    graph.paddingTop    = 5.0f;
    graph.paddingRight  = 5.0f;
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:20.0f];
    [graph.plotAreaFrame setPaddingBottom:35.0f];
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *commutes = [[CPTScatterPlot alloc] init];
    commutes.dataSource = self;
    commutes.delegate = self;
    commutes.plotSymbolMarginForHitDetection = 5.0f;
    CPTColor *commuteColor = [CPTColor colorWithComponentRed:0.184f green:0.223 blue:0.841 alpha:1.0f];
    [graph addPlot:commutes toPlotSpace:plotSpace];
    // 3 - Set up plot space
    plotSpace.allowsUserInteraction = YES;
    CGFloat xMin = 0.0f;
    CGFloat xMax = [[self.fetchedResultsController fetchedObjects] count];
    CGFloat yMin = 0.0f;
    NSNumber *highestNumber = ([NSNumber numberWithInt:([[self longestCommute] intValue] + 2)]);
    CGFloat yMax = [highestNumber floatValue];  // should determine dynamically based on max price
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
    [plotSpace scaleToFitPlots:[graph allPlots]];
    // 4 - Create styles and symbols
    CPTMutableLineStyle *plotLineStyle = [commutes.dataLineStyle mutableCopy];
    plotLineStyle.lineWidth = 2.5;
    plotLineStyle.lineColor = commuteColor;
    commutes.dataLineStyle = plotLineStyle;
    CPTMutableLineStyle *commuteLineStyle = [CPTMutableLineStyle lineStyle];
    commuteLineStyle.lineColor = commuteColor;
    CPTPlotSymbol *commuteSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    commuteSymbol.fill = [CPTFill fillWithColor:commuteColor];
    commuteSymbol.lineStyle = commuteLineStyle;
    commuteSymbol.size = CGSizeMake(6.0f, 6.0f);
    commutes.plotSymbol = commuteSymbol;
}

-(CPTColor*) CPTColorForRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha {
    return [CPTColor colorWithComponentRed:red/255 green:green/255 blue:blue/255 alpha:alpha/255];
}

-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement
{
    return CGPointMake(displacement.x, 0);
}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    if (coordinate == CPTCoordinateY) {
        newRange = ((CPTXYPlotSpace*)space).yRange;
    }
    return newRange;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Signika-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Signika-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Date";
    x.anchorPoint = CGPointMake(1, 0);
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    NSDateFormatter *dF = [[NSDateFormatter alloc] init];
    [self setLabels:x];
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Commute Time";
    y.anchorPoint = CGPointMake(1, 0);
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -20.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 5.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    dF.dateFormat = @"hh:mm:ss";
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    NSNumber *highest = [self longestCommute];
    int highestDiv = [highest intValue] / 2;
    int k = [highest intValue] * 1.5;
    for (int j = 1; j <= k; j++) {
        if ( j % highestDiv == 0) {
            NSString *labelText = [self timeFormatted:j];
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = y.majorTickLength + y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.magnificationFilter = @"";
    y.axisLabels = yLabels;
    NSLog(@"%d, %d, %d", [y.axisLabels count], [y.majorTickLocations count], [y.minorTickLocations count]);
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

-(void) setLabels:(CPTAxis*)axis {
    int dateCount = [[self.fetchedResultsController fetchedObjects] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    CGFloat j = 0;
    for (int i = 0; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
        CPTAxisLabel *label;
        NSString* date = [self stringForRoute:(Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:i]];
        if (dateCount < 5 || i % (dateCount / 5) == 0) {
            label = [[CPTAxisLabel alloc] initWithText:date  textStyle:axis.labelTextStyle];
        }
        else {
            label = [[CPTAxisLabel alloc] initWithText:@""  textStyle:axis.labelTextStyle];
        }
        CGFloat location = j++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = axis.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    axis.axisLabels = xLabels;
    axis.majorTickLocations = xLocations;
}


-(void) plotSpace:(CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate {
    [self setLabels:[self.hostView.hostedGraph.axisSet.axes objectAtIndex:0]];
}

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
    [self initPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[self.fetchedResultsController fetchedObjects] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSInteger valueCount = [[self.fetchedResultsController fetchedObjects] count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            return [self timeIntervalOfRoute:(Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:index]];
            break;
    }
    return [NSDecimalNumber zero];
}



-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
<<<<<<< HEAD
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSString *currentCommuteName = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentCommuteKey];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toCommute.name == '%@'", currentCommuteName];
    [fetchRequest setPredicate:predicate];
    
	NSError *error;
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
<<<<<<< HEAD
    //<<<<<<< HEAD
=======
>>>>>>> Fiddled with graph settings.
    
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Route *route in array) {
        if (route) {
            [self.routeArray addObject:route];
            NSNumber *time = [NSNumber numberWithInteger:[route.endTime timeIntervalSinceDate:route.startTime]];
            [self.timeIntervalArray addObject:time];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"'MM'/'dd'/'yyyy'";
            NSString* dateString = [df stringFromDate:route.endTime];
            [self.dateStringArray addObject:dateString];
        }
<<<<<<< HEAD
        //=======
        //NSLog(@"%@", fetchRequest);
        NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (Route *route in array) {
            NSLog(@"%@", route.toCommute);
            NSLog(@"%@", route);
            [self.routeArray addObject:route];
            NSNumber *time = [NSNumber numberWithInteger:[route.endTime timeIntervalSinceDate:route.startTime]];
            [self.timeIntervalArray addObject:time];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"MM/dd/yyyy";
            NSString* dateString = [df stringFromDate:route.endTime];
            [self.dateStringArray addObject:dateString];
            //>>>>>>> Moar!
        }
        
        NSLog(@"Time Intervals: %@", self.timeIntervalArray);
        NSLog(@"Routes: %@", self.routeArray);
        NSLog(@"Date Strings: %@", self.dateStringArray);
        //<<<<<<< HEAD
        error = nil;
        //=======
        
        //>>>>>>> Moar!
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        if (![self.fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
=======
    //NSLog(@"%@", fetchRequest);
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Route *route in array) {
        NSLog(@"%@", route.toCommute);
        NSLog(@"%@", route);
        [self.routeArray addObject:route];
        NSNumber *time = [NSNumber numberWithInteger:[route.endTime timeIntervalSinceDate:route.startTime]];
        [self.timeIntervalArray addObject:time];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MM/dd/yyyy";
        NSString* dateString = [df stringFromDate:route.endTime];
        [self.dateStringArray addObject:dateString];
    }
    
    NSLog(@"Time Intervals: %@", self.timeIntervalArray);
    NSLog(@"Routes: %@", self.routeArray);
    NSLog(@"Date Strings: %@", self.dateStringArray);
<<<<<<< HEAD
    error = nil;
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
>>>>>>> Fiddled with graph settings.
=======
    NSLog(@"Pressed %d", index);
//    NSLog(@"%@", self.routeArray);
//    Route *route = [self.routeArray objectAtIndex:index];
//    RecieptViewController *rVC = [[RecieptViewController alloc] initWithRoute:route];
//    [self.navigationController pushViewController:rVC animated:YES];
>>>>>>> Merging project from App Beta Code
}

@end
