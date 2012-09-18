//
//  GraphListViewController.m
//  Daily-Commute
//
//  Created by James Allen on 9/1/12.
//  Copyright (c) 2012 James Allen. All rights reserved.
//

#import "StatsViewController.h"
#import "CommuteTimeScatterPlotViewController.h"
#import "BarGraphViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Graphs";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:24];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.shadowOffset = CGSizeMake(0,2);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor =[UIColor whiteColor];
	titleLabel.text = self.title;
    
	self.navigationItem.titleView = titleLabel;
    // Do any additional setup after loading the view from its nib.
    
    self.fetchedResultsController.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //reload data
    NSError *error;
    self.fetchedResultsController = nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}


-(NSString *)currentCommuteName{
     return [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentCommuteKey];
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        return 8;
    }
    return 1;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row < 2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GraphCell"];
    }
    else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GraphCell"];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Signika-Bold" size:17];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Signika-Bold" size:17];
    if ([self.fetchedResultsController fetchedObjects].count > 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Commute History Graph";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text = @"Time Bar Graph";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 2:
                cell.textLabel.text = @"Fastest Time";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self timeRecord:NO]];
                break;
            case 3:
                cell.textLabel.text = @"Slowest Time";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self timeRecord:YES]];
                break;
            case 4:
                cell.textLabel.text = @"Average Time";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self averageTime]];
                break;
            case 5:
                cell.textLabel.text = @"This Day Last Week";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self thisDayLast:@"Week"]];
                break;
            case 6:
                cell.textLabel.text = @"This Day Last Month";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self thisDayLast:@"Month"]];
                break;
            case 7:
                cell.textLabel.text = @"This Day Last Year";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self thisDayLast:@"Year"]];
                break;
            default:
                break;
        }
    }
    else {
        cell.textLabel.text = @"You must run at least one commute.";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(NSString*) thisDayLast:(NSString*)timePeriod {
    NSDate *dateToCompare;
    NSString* time = @"-";
    NSCalendar *gregCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregCalendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    if ([timePeriod isEqualToString:@"Week"]) {
        [components setDay:components.day - 7];
    }
    else if ([timePeriod isEqualToString:@"Month"]) {
        NSInteger month = [components month];
        NSInteger year = [components year];
        if (month == 12) {
            [components setYear:year - 1];
            [components setMonth:1];
        }
        else {
            [components setMonth:month - 1];
        }
    }
    else if ([timePeriod isEqualToString:@"Year"]) {
        NSInteger year = [components year];
        [components setYear:year - 1];
    }
    dateToCompare = [[gregCalendar dateFromComponents:components] dateByAddingTimeInterval:0];
    int index = -1;
    for (int i = 0; i < [[self.fetchedResultsController fetchedObjects] count]; i++) {
        Route *r = (Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:i];
        NSDate *endTime = [self normalizedDateWithDate:r.endTime];
        if (dateToCompare == endTime) {
            index = i;
            break;
        }
    }
    NSDateFormatter *dF = [[NSDateFormatter alloc] init];
    dF.dateFormat = @"hh:mm:ss";
    if (index != -1) {
        Route *finalRoute = (Route*)[[self.fetchedResultsController fetchedObjects] objectAtIndex:index];
        NSDate *finalDate = [self normalizedDateWithDate:finalRoute.endTime];
        time = [dF stringFromDate:finalDate];
    }
    return time;
}

-(NSString*) timeRecord:(BOOL)slow {
    NSString *time = @"-";
    Route *recordRoute = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
    BOOL comparison;
    for (Route* r in [self.fetchedResultsController fetchedObjects]) {
        if (slow) {
            comparison = [r.endTime timeIntervalSinceDate:r.startTime] < [recordRoute.endTime timeIntervalSinceDate:recordRoute.startTime];
        }
        else {
            comparison = [r.endTime timeIntervalSinceDate:r.startTime] > [recordRoute.endTime timeIntervalSinceDate:recordRoute.startTime];
        }
        if (comparison) {
            recordRoute = r;
        }
    }
    time = [self timeFormatted:(int)[recordRoute.endTime timeIntervalSinceDate:recordRoute.startTime]];
    return time;
}

-(NSString*) averageTime {
    NSString *time;
    int averageTimeInSeconds = 0;
    int allTimesAdded = 0;
    for (Route* r in [self.fetchedResultsController fetchedObjects]) {
        allTimesAdded += [r.endTime timeIntervalSinceDate:r.startTime];
    }
    averageTimeInSeconds = allTimesAdded / [[self.fetchedResultsController fetchedObjects] count];
    time = [self timeFormatted:averageTimeInSeconds];
    return time;
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"count - %i",[[self.fetchedResultsController fetchedObjects] count]);
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        switch (indexPath.row) {
            case 0:
                [self viewCommuteGraph];
                break;
            case 1:
                [self viewBarGraph];
                break;
            default:
                break;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) viewCommuteGraph {
    CommuteTimeScatterPlotViewController *ctGraph = [[CommuteTimeScatterPlotViewController alloc] init];
    [self.navigationController pushViewController:ctGraph animated:YES];
}

-(void) viewBarGraph {
    BarGraphViewController *bgGraph = [[BarGraphViewController alloc] init];
    [self.navigationController pushViewController:bgGraph animated:YES];
}

-(NSDate*)normalizedDateWithDate:(NSDate*)date
{
    NSDateComponents* components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                               fromDate:date];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

//- (void) fetchResults
//{
//    if (!self.routeArray) {
//        self.routeArray = [[NSMutableArray alloc] init];
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
//        NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//        for (Route *route in array) {
//            [self.routeArray addObject:route];
//        }
//        NSLog(@"%@", self.routeArray);
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

#pragma mark - Fetched results controller

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

@end

