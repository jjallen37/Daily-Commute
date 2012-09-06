//
//  StatsViewController.m
//  DailyCommute
//
//  Created by Weston Catron on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatsViewController.h"
#import "AppDelegate.h"

@implementation StatsViewController

@synthesize delegate,toRoutes = _toRoutes,fromRoutes = _fromRoutes,currentDatePicker,dateFormatter,currentCommute;
@synthesize toDate = _toDate, fromDate = _fromDate,toAndFromRoutes = _toAndFromRoutes;
@synthesize totalsGraphVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (IBAction)showHideStatsView:(id)sender {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"isProUpgradePurchased"]){
        [adBanner setHidden:YES];
    } else {
        [adBanner setHidden:NO];
    }
    toRoutesNeedsUpdating = YES;
    fromRoutesNeedsUpdating = YES;
    if ([delegate isInRoute])
        return;
    if (!ShowingView) {
        
        [backgroundImageView setImage:[UIImage imageNamed:@"StatHide.png"]];
        [self showStatsView];
        
        currentCommute = [delegate getCurrentCommute];
        
        [graphView setBackgroundColor:[UIColor clearColor]];
        [statsTableView setBackgroundColor:[UIColor clearColor]];
        
        [self reloadGraphView];
        
        ShowingView = YES;
    } else {
        [backgroundImageView setImage:[UIImage imageNamed:@"StatNormal.png"]];
        [self hideStatsView];
        ShowingView = NO;
        [self refreshTopStats];
        
        [self closeRecieptViewWithNoChanges];
        
    }
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideDateLengthButtons];
    ShowingView = NO;
    //currentDatePicker = [[UIDatePicker alloc] init];
    [currentDatePicker setDatePickerMode:UIDatePickerModeDate];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    [[toDateButton titleLabel] setFont:[UIFont fontWithName:@"Signika-Bold" size:14]];
    [toDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [toDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [toDateButton setTitle:[dateFormatter stringFromDate:[self getToDate]] forState:UIControlStateNormal];
    
    [[fromDateButton titleLabel] setFont:[UIFont fontWithName:@"Signika-Bold" size:14]];
    [fromDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fromDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [fromDateButton setTitle:[dateFormatter stringFromDate:[self getFromDate]] forState:UIControlStateNormal];
    
    /*UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(switchCurrentView:)];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[self.view addGestureRecognizer:panRecognizer];*/
    
    showingGraph = YES;
    showingToTopStats = YES;
    toRoutesNeedsUpdating = YES;
    fromRoutesNeedsUpdating = YES;
    [self refreshTopStats];
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewGraph:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [statsTableView addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer2;
    
    recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewList:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [graphView addGestureRecognizer:recognizer2];
    
    //Set fonts
    [self setFonts];
    
    totalsGraphVC = [[TotalsGraph alloc] init];
    
    [totalsGraphVC setView:graphView];
    [totalsGraphVC setDataSource:self];
    [graphView setDataSource:totalsGraphVC];
    
}

- (void)setFonts {
    UIFont *font = [UIFont fontWithName:@"Signika-Bold" size:15];
    [previousLabel setFont:font];
    [averageLabel setFont:font];
    [slowestLabel setFont:font];
    [fastestLabel setFont:font];
    
    font = [UIFont fontWithName:@"Signika-Bold" size:14];
    [previousTitle setFont:font];
    [averageTitle setFont:font];
    [slowestTitle setFont:font];
    [fastestTitle setFont:font];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    startPoint = [[[event allTouches] anyObject] locationInView:self.view];
    
    if (startPoint.y < 36) {
        if (startPoint.x < 60) {
            NSLog(@"Left Button Pressed");
            
            [self closeRecieptViewWithNoChanges ];
        } else if (startPoint.x > 260) {
            [UIView animateWithDuration:.7
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                             animations:^{[currentRouteView setFrame:CGRectMake(0, 460, 320, 343)];}
                             completion:nil];
            
            [delegate hideCancelButton];
            
            [self reloadGraphView];
            
            NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            NSError *error;
            [context save:&error];
            [recieptViewController closeKeyboard:recieptViewController];
        }
    }
}

- (void)closeRecieptViewWithNoChanges { 
    [UIView animateWithDuration:.7
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentRouteView setFrame:CGRectMake(0, 460, 320, 343)];}
                     completion:nil];
    [delegate hideCancelButton];
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context rollback];
    
    [recieptViewController closeKeyboard:recieptViewController];
    
    [statsTableView reloadData];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /*CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    
    if (point.x > startPoint.x && (point.x-startPoint.x) > 40) {
        [self viewGraph];
    }
    
    if (point.x < startPoint.x && (startPoint.x-point.x) > 40) {
        [self viewList];
    }
     */
    
}

- (IBAction)switchCurrentView:(id)sender {
    if (showingGraph) {
        [self viewList];
        showingGraph = NO;
    } else {
        [self viewGraph];
        showingGraph = YES;
    }
}

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    if (point.y < 30 && point.x > 260) {
        [delegate toggleStatMapAndGraph:self];
    }
}*/


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) isStatsViewOpen {
    return ShowingView;
}

#pragma mark - Top Stats

-(IBAction)toggleToFromTopStats:(id)sender {
    if (showingToTopStats) {
        showingToTopStats = NO;
    } else {
        showingToTopStats = YES;
    }
    [self refreshTopStats];
}

-(void)refreshTopStats {
    NSArray *routesTemp;
    if (showingToTopStats) {
        [topStatsImageView setImage:[UIImage imageNamed:@"To.png"]];
    } else {
        [topStatsImageView setImage:[UIImage imageNamed:@"From.png"]];
    }
    if (ShowingView) {
        if (showingToTopStats) {
            routesTemp = [self toRoutes];
        } else {
            routesTemp = [self fromRoutes];
        }
        
    } else {
        
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSPredicate *predicate;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Route"];
        if (showingToTopStats) {
            predicate = [NSPredicate predicateWithFormat:@"toCommute == %@", [delegate getCurrentCommute]];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"fromCommute == %@", [delegate getCurrentCommute]];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
        
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        routesTemp = [context executeFetchRequest:request error:&error];  
    }
   
    if ([routesTemp count] == 0) {
        
        [averageLabel setText:@"00:00:00"];
        [previousLabel setText:@"00:00:00"];
        [slowestLabel setText:@"00:00:00"];
        [fastestLabel setText:@"00:00:00"];
        
        return;
    }
    
    int average = 0;
    int previous = 0;
    int slowest = 0;
    int fastest = 99999;
    
    NSInteger current;
    for (Route *route in routesTemp) {
        current = (NSInteger)[route.endTime timeIntervalSinceDate:route.startTime];
        if (current > slowest) {
            slowest = current;
        }
        if (current < fastest) {
            fastest = current;
        }
        average += current;
        previous = current; //will reset every time and the last time will be THE last time and therefore the last route's time.
    }
    
    if ([routesTemp count] != 0) {
        average = average/[routesTemp count];
    }
    
    NSInteger seconds = average % 60;
    NSInteger minutes = (average / 60) % 60;
    NSInteger hours = (average / 3600);
    
    [averageLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
    
    seconds = previous % 60;
    minutes = (previous / 60) % 60;
    hours = (previous / 3600);
    
    [previousLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
    
    seconds = slowest % 60;
    minutes = (slowest / 60) % 60;
    hours = (slowest / 3600);
    
    [slowestLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
    
    seconds = fastest % 60;
    minutes = (fastest / 60) % 60;
    hours = (fastest / 3600);
    
    [fastestLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
}
/*
#pragma mark - Graph Datasource

-(NSInteger)numberOfLinesOnGraph:(GraphView *)graphView {
    if ([[self getToRoutes] count] > 0 && [[self getFromRoutes] count] > 0) {
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
        NSLog(@"Number of Points on Graph: %i",[[self getToRoutes] count]);
        return [[self getToRoutes] count];
    }
    NSLog(@"Number of Points on Graph: %i",[[self getFromRoutes] count]);
    return [[self getFromRoutes] count];
}
-(NSInteger)valueForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    if (lineNumber == 0) {
        return [[(Route *)[self.toRoutes objectAtIndex:point] endTime] timeIntervalSinceDate:[(Route *)[self.toRoutes objectAtIndex:point] startTime]];
    }
    return [[(Route *)[self.fromRoutes objectAtIndex:point] endTime] timeIntervalSinceDate:[(Route *)[self.fromRoutes objectAtIndex:point] startTime]];
}
-(NSDate *)dateForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber {
    if (lineNumber == 0) {
        return [(Route *)[self.toRoutes objectAtIndex:point] endTime];
    }
    return [(Route *)[self.fromRoutes objectAtIndex:point] endTime];
}


-(NSInteger)greatestValueOnGraph:(GraphView *)graphView {
    int highestValue = 0;
    int comparisonValue = 0;
    
    for (Route *route in [self getToRoutes]) {
        comparisonValue = [[route endTime] timeIntervalSinceDate:[route startTime]];
        if (comparisonValue > highestValue) {
            highestValue = comparisonValue;
        }
    }
    
    for (Route *route in [self getFromRoutes]) {
        comparisonValue = [[route endTime] timeIntervalSinceDate:[route startTime]];
        if (comparisonValue > highestValue) {
            highestValue = comparisonValue;
        }
    }
    
    return highestValue*1.25;
}*/

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"Vied Did Appear");
    if ([self isStatsViewOpen]) {
        [self showStatsView];
    }
}

#pragma mark - Date To From

- (IBAction)promptToDate:(id)sender {
    [self showDateLengthButtons];
    if (showingFromDatePrompt) {
        [self finalizeFromDate:self];
        [self promptToDate:self];
        return;
    }
    [toDateButton removeTarget:self action:@selector(promptToDate:) forControlEvents:UIControlEventTouchUpInside];
    [currentDatePicker setFrame:CGRectMake(0, 444, 320, 216)];
    [currentDatePicker setMinimumDate:self.fromDate];
    [currentDatePicker setMaximumDate:[NSDate date]];
    [currentDatePicker setDate:self.toDate];
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentDatePicker setFrame:CGRectMake(0, 194, 320,216)];}
                     completion:nil];
    [toDateButton setTitle:@"Tap to Set" forState:UIControlStateNormal];
    [toDateButton addTarget:self action:@selector(finalizeToDate:) forControlEvents:UIControlEventTouchUpInside];
    showingToDatePrompt = YES;
}

- (IBAction)finalizeToDate:(id)sender {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentDatePicker setFrame:CGRectMake(0, 464, 320,216)];}
                     completion:nil];
    
    [self setToDate:[currentDatePicker date]];
    [toDateButton addTarget:self action:@selector(promptToDate:) forControlEvents:UIControlEventTouchUpInside];
    showingToDatePrompt = NO;
    [self hideDateLengthButtons];
}

- (IBAction)promptFromDate:(id)sender {
    [self showDateLengthButtons];
    if (showingToDatePrompt) {
        [self finalizeToDate:self];
        [self promptFromDate:self];
        return;
    }
    [fromDateButton removeTarget:self action:@selector(promptFromDate:) forControlEvents:UIControlEventTouchUpInside];
    [currentDatePicker setFrame:CGRectMake(0, 464, 320, 216)];
    [currentDatePicker setMinimumDate:nil];
    [currentDatePicker setMaximumDate:self.toDate];
    [currentDatePicker setDate:self.fromDate];
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentDatePicker setFrame:CGRectMake(0, 194, 320,216)];}
                     completion:nil];
    [fromDateButton setTitle:@"Tap to Set" forState:UIControlStateNormal];
    [fromDateButton addTarget:self action:@selector(finalizeFromDate:) forControlEvents:UIControlEventTouchUpInside];
    showingFromDatePrompt = YES;
}

- (IBAction)finalizeFromDate:(id)sender {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentDatePicker setFrame:CGRectMake(0, 464, 320,216)];}
                     completion:nil];
    
    [self setFromDate:[currentDatePicker date]];
    [fromDateButton addTarget:self action:@selector(promptFromDate:) forControlEvents:UIControlEventTouchUpInside];
    showingFromDatePrompt = NO;
    [self hideDateLengthButtons];
}

- (void)setToDate:(NSDate *)aDate {
    [toDateButton setTitle:[dateFormatter stringFromDate:aDate] forState:UIControlStateNormal];
    _toDate = aDate;
    [self reloadGraphView];
}
- (void)setFromDate:(NSDate *)aDate {
    [fromDateButton setTitle:[dateFormatter stringFromDate:aDate] forState:UIControlStateNormal];
    _fromDate = aDate;
    [self reloadGraphView];
}

- (NSDate *)getToDate {
    if (_toDate == nil) {
        NSDate *today = [NSDate date];
        _toDate = today;
        return _toDate;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //Strip time off the time.
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: _toDate];
    
    _toDate = [gregorian dateFromComponents:components];
    
    return _toDate;
}

- (NSDate *)getFromDate {
    if (_fromDate == nil) { 
        
        NSDate *today = [NSDate date];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        
        NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit
                                                           fromDate:today];
        
        [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
        
        NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
        
        
        //Strip time off the time.
        NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
        beginningOfWeek = [gregorian dateFromComponents:components];
                
        _fromDate = beginningOfWeek;
        
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    //Strip time off the time.
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: _fromDate];
    
    _fromDate = [gregorian dateFromComponents:components];
    
    return _fromDate;
}

#pragma mark - Reload Graph

- (void) reloadGraphView {
    
    NSLog(@"To count: %i From count: %i",[self.toRoutes count],[self.fromRoutes count]);
    toRoutesNeedsUpdating = YES;
    fromRoutesNeedsUpdating = YES;
    [graphView setNeedsDisplay];
    [statsTableView reloadData];
    [self refreshTopStats];
}

#pragma mark - tableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:16]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:16]];
    
    Route *route = [[self getToAndFromRoutes] objectAtIndex:indexPath.row];
    
    if ([route toCommute] != nil) {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ - To",[dateFormatter stringFromDate:[route endTime]]]];
    } else {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ - From",[dateFormatter stringFromDate:[route endTime]]]];
    }
    
    NSInteger ti = (NSInteger)[route.endTime timeIntervalSinceDate:route.startTime];
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
     
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Number of Routes for TV: %i",[[self getToRoutes] count]);
    return [[self getToAndFromRoutes] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == statsTableView) {
        [delegate showExAndCheckButtons];
        recieptViewController = [[RecieptViewController alloc] initWithNibName:@"RecieptViewController" bundle:nil];
        [recieptViewController setRoute:[[self getToAndFromRoutes] objectAtIndex:indexPath.row]];
        
        [recieptViewController.view setFrame:CGRectMake(0, 460, 320, 343)];
        
        currentRouteView = recieptViewController.view;
        
        [self.view addSubview:currentRouteView];
        
        [UIView animateWithDuration:.7
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                         animations:^{[currentRouteView setFrame:CGRectMake(0, 47, 320, 343)];}
                         completion:nil];
        showingRoute = YES;
        
        [delegate showCancelButton];
    }
}

- (NSArray *)getToRoutes {
    if (toRoutesNeedsUpdating) {
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Route"];
        
        //int days = 3;
        //NSLog(@"Predicate: (endTime >= %@) AND (endTime =< %@) AND (toCommute == %@)", [self getFromDate], [self getToDate],[delegate getCurrentCommute]);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(endTime >= %@) AND (endTime <= %@) AND (toCommute == %@)", [self getFromDate], [NSDate dateWithTimeInterval:60*60*24 sinceDate:[self getToDate]],[delegate getCurrentCommute]];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(toCommute == %@)", currentCommute];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
        
        
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        _toRoutes = [context executeFetchRequest:request error:&error]; 
        toRoutesNeedsUpdating = NO;
    }
    return _toRoutes;
}

- (NSArray *)getFromRoutes {
    if (fromRoutesNeedsUpdating) {
        NSLog(@"Reloading Routes");
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Route"];
        
        //int days = 3;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(endTime >= %@) AND (endTime <= %@) AND (fromCommute == %@)", [self getFromDate], [NSDate dateWithTimeInterval:60*60*24 sinceDate:[self getToDate]],[delegate getCurrentCommute]];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(toCommute == %@)", currentCommute];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
        
        
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        _fromRoutes = [context executeFetchRequest:request error:&error];  
        fromRoutesNeedsUpdating = NO;
    }
    return _fromRoutes;
}

- (NSArray *)getToAndFromRoutes {
    NSMutableArray *currentToRoutes = [NSMutableArray arrayWithArray:[self getToRoutes]];
    
    [currentToRoutes addObjectsFromArray:[self getFromRoutes]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
    
    [currentToRoutes sortUsingDescriptors:sortDescriptors];
        
    _toAndFromRoutes = currentToRoutes;
    
    return [NSArray arrayWithArray:currentToRoutes];
}

- (void)viewGraph {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[statsTableView setFrame:CGRectMake(325, 160, 310, 225)];
                         [graphView setFrame:CGRectMake(13, 160, 295, 225)];}
                     completion:nil];
    [pageControl setCurrentPage:0];
}

-(IBAction)viewGraph:(id)sender {
    [self viewGraph];
}

- (void)viewList {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[statsTableView setFrame:CGRectMake(5, 160, 310, 225)];[graphView setFrame:CGRectMake(-345, 160, 295, 225)];}
                     completion:nil];
     [pageControl setCurrentPage:1];
}

-(IBAction)viewList:(id)sender {
    [self viewList];
}

#pragma mark - iAds

//Doesn't work I just wanted it to shut up.

-(void)didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Poor thing");
}

#pragma mark - Buttons

-(void)hideDateLengthButtons {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[weekButton setAlpha:0.0];
                         [monthButton setAlpha:0.0];
                         [yearButton setAlpha:0.0];}
                     completion:nil];
}

-(void)showDateLengthButtons {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[weekButton setAlpha:1.0];
                         [monthButton setAlpha:1.0];
                         [yearButton setAlpha:1.0];}
                     completion:nil];
}

- (IBAction)weekButtonPress:(id)sender {
    [self setToDate:[NSDate date]];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    [components setDay:([components day] - 7)];
    NSDate *lastWeek  = [cal dateFromComponents:components];
    [self setFromDate:lastWeek];
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentDatePicker setFrame:CGRectMake(0, 464, 320,216)];}
                     completion:nil];
    [self hideDateLengthButtons];
    
}

- (IBAction)monthButtonPressed:(id)sender {
    [self setToDate:[NSDate date]];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    [components setMonth:([components month] - 1)]; 
    NSDate *lastMonth = [cal dateFromComponents:components];
    [self setFromDate:lastMonth];
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentDatePicker setFrame:CGRectMake(0, 464, 320,216)];}
                     completion:nil];
    [self hideDateLengthButtons];
}

-(IBAction)yearButtonPressed:(id)sender {
    [self setToDate:[NSDate date]];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate dateWithTimeIntervalSinceNow:0]];

    [components setYear:([components year] - 1)]; 
    NSDate *lastYear = [cal dateFromComponents:components];
    [self setFromDate:lastYear];
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[currentDatePicker setFrame:CGRectMake(0, 464, 320,216)];}
                     completion:nil];
    [self hideDateLengthButtons];
}


-(void)showStatsView {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[self.view setFrame:CGRectMake(0, 0, 320,480)];}
                     completion:nil];
    
}
-(void)hideStatsView {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[self.view setFrame:CGRectMake(0, 341, 320, 480)];}
                     completion:nil];
}
-(void)disappearStatsView {
    [UIView animateWithDuration:.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
                     animations:^{[self.view setFrame:CGRectMake(0, 480, 320, 480)];}
                     completion:nil];
}

@end
