//
//  ScatterPlotViewController.m
//  CorePlot
//
//  Created by Harlan Haskins on 8/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "CommuteTimeScatterPlotViewController.h"
#import "Route.h"

@interface CommuteTimeScatterPlotViewController ()

@end

@implementation CommuteTimeScatterPlotViewController

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [self fetchResults];
    [super viewDidAppear:animated];
<<<<<<< HEAD
    [self initPlot];
    [self fetchResults];
=======
>>>>>>> Moar!
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
    self.hostView.allowPinchScaling = NO;
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Commutes";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Signika-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *commutes = [[CPTScatterPlot alloc] init];
    commutes.dataSource = self;
    CPTColor *commuteColor = [CPTColor colorWithComponentRed:0.2f green:0.788f blue:0.0f alpha:1.0f];
    [graph addPlot:commutes toPlotSpace:plotSpace];
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:@[commutes]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
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
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [self.dateStringArray count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    for (NSString *date in self.dateStringArray) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Commute Time";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 100;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 700.0f;  // should determine dynamically based on highest time.
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
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
    [self initPlot];
    self.timeIntervalArray = [[NSMutableArray alloc] init];
    self.dateStringArray = [[NSMutableArray alloc] init];
    self.routeArray = [[NSMutableArray alloc] init];
    [super viewDidLoad];
<<<<<<< HEAD
	// Do any additional setup after loading the view.
    self.timeIntervalArray = [[NSMutableArray alloc] init];
    self.dateStringArray = [[NSMutableArray alloc] init];
    self.routeArray = [[NSMutableArray alloc] init];
=======
>>>>>>> Moar!
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.timeIntervalArray count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSInteger valueCount = [self.timeIntervalArray count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            return [self.timeIntervalArray objectAtIndex:index];
            break;
    }
    return [NSDecimalNumber zero];
}

#pragma mark - Fetched results controller

- (void) fetchResults
{
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
>>>>>>> Moar!
    }
    
    NSLog(@"Time Intervals: %@", self.timeIntervalArray);
    NSLog(@"Routes: %@", self.routeArray);
    NSLog(@"Date Strings: %@", self.dateStringArray);
<<<<<<< HEAD
    error = nil;
=======
    
>>>>>>> Moar!
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

@end
