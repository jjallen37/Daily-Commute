//
//  GraphViewController.m
//  Daily-Commute
//
//  Created by James Allen on 9/1/12.
//  Copyright (c) 2012 James Allen. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()

@end


@implementation GraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //reload data
    NSError *error;
    self.fetchedResultsController = nil;
    [self.fetchedResultsController performFetch:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Load the context if needed
    if (self.managedObjectContext == nil)
    {
        self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.currentCommuteName = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentCommuteKey];
    [self.view addSubview:self.hostView];
    self.title = @"Past Commutes";
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:24];
	_titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    _titleLabel.shadowOffset = CGSizeMake(0,2);
	_titleLabel.textAlignment = UITextAlignmentCenter;
	_titleLabel.textColor =[UIColor whiteColor];
	_titleLabel.text = self.title;
	self.navigationItem.titleView = _titleLabel;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

-(NSNumber*) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    return 0;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 0;
}

-(CGPoint) plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)proposedDisplacementVector {
    return CGPointMake(proposedDisplacementVector.x, 0);
}

-(CPTPlotRange*) plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate {
    if (coordinate == CPTCoordinateY) {
        newRange = ((CPTXYPlotSpace*)space).yRange;
    }
    return newRange;
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

-(NSNumber*) longestCommute {
    NSNumber *highestNumber = [self timeIntervalOfRoute:[[self.fetchedResultsController fetchedObjects] objectAtIndex:0]];
    for (int i = 0; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
        NSNumber* n = [self timeIntervalOfRoute:[[self.fetchedResultsController fetchedObjects] objectAtIndex:i]];
        if ([n isGreaterThan:highestNumber]) {
            highestNumber = n;
        }
    }
    return highestNumber;
}

-(NSNumber*) longestDelay {
    Route* routeToCompare = (Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
    NSNumber *highestNumber = [self delayOfRoute:routeToCompare];
    for (Route* r in [self.fetchedResultsController fetchedObjects]) {
        NSNumber *n = [self timeIntervalIgnoringDateFrom:r.endTime to:r.toCommute.toArrivalTime];
        if ([n isGreaterThan:highestNumber]) {
            highestNumber = n;
        }
    }
    return highestNumber;
}

-(NSNumber*) shortestCommute {
    NSNumber *lowestNumber = [self timeIntervalOfRoute:[[self.fetchedResultsController fetchedObjects] objectAtIndex:0]];
    for (int i = 0; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
        NSNumber* n = [self timeIntervalOfRoute:[[self.fetchedResultsController fetchedObjects] objectAtIndex:i]];
        if ([n isLessThan:lowestNumber]) {
            lowestNumber = n;
        }
    }
    return lowestNumber;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController popViewControllerAnimated:NO];
}

-(NSNumber*) timeIntervalOfRoute:(Route*)route {
    return @([route.endTime timeIntervalSinceDate:route.startTime]);
}

-(NSString*) stringForRoute:(Route*)route {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd";
    NSString* dateString = [df stringFromDate:route.endTime];
    return dateString;
}

-(NSNumber*) delayOfRoute:(Route*)route {
    NSNumber *delay = [self timeIntervalIgnoringDateFrom:route.endTime to:route.toCommute.toArrivalTime];
    return delay;
}

#pragma mark - Fetched results controller

//- (void) fetchResults
//{
//    if (!(self.timeIntervalArray || self.dateStringArray || self.routeArray)) {
//        self.timeIntervalArray = [[NSMutableArray alloc] init];
//        self.dateStringArray = [[NSMutableArray alloc] init];
//        self.routeArray = [[NSMutableArray alloc] init];
//        self.delayIntervalArray = [[NSMutableArray alloc] init];
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        // Edit the entity name as appropriate.
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        
//        // Set the batch size to a suitable number.
//        [fetchRequest setFetchBatchSize:20];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toCommute.name == %@", self.currentCommuteName];
//        [fetchRequest setPredicate:predicate];
//        
//        NSError *error;
//        
//        // Edit the sort key as appropriate.
//        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
//        [fetchRequest setSortDescriptors:@[sortDescriptor]];
//        NSLog(@"%@", fetchRequest);
//        NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        for (Route *route in array) {
//            NSLog(@"%@", route.toCommute);
//            NSLog(@"%@", route);
//            [self.routeArray addObject:route];
//            NSNumber *time = [NSNumber numberWithInteger:[route.endTime timeIntervalSinceDate:route.startTime]];
//            [self.timeIntervalArray addObject:time];
//            NSDateFormatter *df = [[NSDateFormatter alloc] init];
//            df.dateFormat = @"MM/dd";
//            NSString* dateString = [df stringFromDate:route.endTime];
//            [self.dateStringArray addObject:dateString];
//            //NSNumber* timeIntervalOfIdealNonDelayedCommuteGivenStartTime = [self timeIntervalIgnoringDateFrom:route.startTime to:route.toCommute.toArrivalTime];
//            //NSNumber *delay = [NSNumber numberWithDouble:([timeIntervalOfIdealNonDelayedCommuteGivenStartTime doubleValue] - [time doubleValue])];
//            
//            NSNumber *delay = [self timeIntervalIgnoringDateFrom:route.endTime to:route.toCommute.toArrivalTime];
//            
//            //If there is a delay, add it to the delay list. Otherwise, fill it with a -1.
//            
//            NSNumber *numberToAdd = [delay isLessThan:@0] ? @0 : delay;
//            [self.delayIntervalArray addObject:numberToAdd];
//        }
//        
//        // Edit the section name key path and cache name if appropriate.
//        // nil for section name key path means "no sections".
//        
//        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//        aFetchedResultsController.delegate = self;
//        self.fetchedResultsController = aFetchedResultsController;
//        
//        if (![self.fetchedResultsController performFetch:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toCommute.name == %@", self.currentCommuteName];
    [fetchRequest setPredicate:predicate];
    
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

-(NSNumber*) timeIntervalIgnoringDateFrom:(NSDate*) startTime to:(NSDate*)endTime {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *startComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:startTime];
    
    NSDateComponents *endComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:endTime];
    
    NSDate *startDate = [gregorian dateFromComponents:startComponents];
    
    NSDate *endDate = [gregorian dateFromComponents:endComponents];
    
    NSNumber *interval = [NSNumber numberWithDouble:[startDate timeIntervalSinceDate:endDate]];
    
    return interval;
}

@end
