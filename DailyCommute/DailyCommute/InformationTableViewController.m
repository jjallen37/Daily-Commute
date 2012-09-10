//
//  InformationTableViewController.m
//  DailyCommute
//
//  Created by Weston Catron on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "InformationTableViewController.h"
#import "CountDownViewController.h"
#import "Route.h"
#import "RootViewController.h"
#import "TutorialModalViewController.h"

#define kNameTextFieldIndex 37
#define kArrivalTimeTextFieldIndex 42

@implementation InformationTableViewController

@synthesize commute;
@synthesize info,keys;
@synthesize averageTime;
@synthesize parentViewController;


-(id) initWithCommute:(Commute *)newCommute{
    commute = newCommute;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"HH:mm A"];
    
    return [self initWithStyle:UITableViewStylePlain];

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    
     [self performSelector:@selector(updateCountDown:) withObject:nil afterDelay:1.0];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)updateInfo:(Commute*)sender{

    commute = sender;
    
    [self.tableView reloadData];
}



- (NSTimeInterval )getAverageTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *routesTemp = [[commute toRoute] allObjects];
    
    NSTimeInterval average = 0;
    
    NSInteger current;
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:(NSWeekdayCalendarUnit | NSDayCalendarUnit) fromDate:currentDate];
    
    if ([userDefaults objectForKey:kDataFilterKey]==kDataFilterTypeWeek) {//Based on week day data
        
        NSUInteger count = 0;
        
        for (Route *route in routesTemp) {
            NSDate *startTime = route.startTime;
            NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSWeekdayCalendarUnit) fromDate:startTime];
            if (comps.weekday == currentComponents.weekday) {
                current = (NSInteger)[route.endTime timeIntervalSinceDate:route.startTime];
                average += current;
                count++;
            }

        }
        
        if ([routesTemp count] != 0) {
            average = average/count;
        } else {
            average = 0;
        }
        
        return average;
    }else if([userDefaults objectForKey:kDataFilterKey]==kDataFilterTypeMonth){//Based on past month data
        
        NSUInteger count = 0;
        
        for (Route *route in routesTemp) {
            NSDate *startTime = route.startTime;
            NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:startTime];
            if (comps.day == currentComponents.day) {
                current = (NSInteger)[route.endTime timeIntervalSinceDate:route.startTime];
                average += current;
                count++;
            }
            
        }
        
        if ([routesTemp count] != 0) {
            average = average/count;
        } else {
            average = 0;
        }
        
        return average;
        
    }else{//All Commutes

        for (Route *route in routesTemp) {
            current = (NSInteger)[route.endTime timeIntervalSinceDate:route.startTime];
            
            average += current;
        }
        
        if ([routesTemp count] != 0) {
            average = average/[routesTemp count];
        } else {
            average = 0;
        }
        
        return average;
    }
}




- (NSTimeInterval )getTimeTilDepart {
    NSDate *arriveTime = commute.toArrivalTime;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:arriveTime];
    
    NSDateComponents *nowComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    NSDate *todayAriveTime = [gregorian dateByAddingComponents:timeComponents toDate:[gregorian dateFromComponents:nowComponents] options:0];
    
    
    //NSLog(@"Average Time: %@",todayAriveTime);
    
    NSDate *timeToDepart = [todayAriveTime dateByAddingTimeInterval:-(int)[self getAverageTime]];
    NSTimeInterval timeTilDepart = [[NSDate date] timeIntervalSinceDate:timeToDepart];
    
    return -timeTilDepart;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4; //5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"InfoTableCell";
    
    InfoTableCell *cell = (InfoTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
    
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InfoTableCell" owner:self options:nil];
    
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell =  (InfoTableCell *) currentObject;
                break;
            }
        }
    }
        
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];
        
        
    NSDate *timeToDepart = [commute.toArrivalTime dateByAddingTimeInterval:-(int)[self getAverageTime]];
    NSTimeInterval timeTilDepart = [self getTimeTilDepart];
    NSDate *estimatedArrivalTime = [[NSDate date] dateByAddingTimeInterval:averageTime];
    //NSLog(@"time to depart - %@",[dateFormatter stringFromDate:timeToDepart]);
    
    BOOL isTimeTilDepartNegative = NO;
    
    if (timeTilDepart < 0) {
        timeTilDepart = -timeTilDepart;
        isTimeTilDepartNegative = YES;
    }
    
    NSInteger seconds = (int)timeTilDepart % 60;
    NSInteger minutes = ((int)timeTilDepart / 60) % 60;
    NSInteger hours = ((int)timeTilDepart / 3600);
    
    NSString *hoursString = [NSString stringWithFormat:@"%i",hours];
    NSString *minutesString = [NSString stringWithFormat:@"%i",minutes];
    NSString *secondsString  = [NSString stringWithFormat:@"%i",seconds];
    
    if (hours < 10)
        hoursString = [NSString stringWithFormat:@"0%i",hours];
    if (minutes < 10)
        minutesString = [NSString stringWithFormat:@"0%i",minutes];
    if (seconds < 10)
        secondsString = [NSString stringWithFormat:@"0%i",seconds];
    
    NSString *departIn = [NSString stringWithFormat:@"%@:%@:%@",hoursString,minutesString,secondsString];
    
    if (isTimeTilDepartNegative && timeTilDepart > [self averageTime]) {
        isTimeTilDepartNegative = NO;
        departIn = @"-";
    }
    
    NSArray *routesTemp = [[commute toRoute] allObjects];


    [cell.infoTitleLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:19]];
    [cell.infoDetailLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:17]];
    cell.clockImageView.alpha = 0.0;
    switch (indexPath.row) {
        case 1:
            cell.infoTitleLabel.text = @"Depart By";
            if (timeToDepart != commute.toArrivalTime) {
                cell.infoDetailLabel.text = [dateFormatter stringFromDate:timeToDepart];
            } else {
                cell.infoDetailLabel.text = @"-";
            }
            
            if([routesTemp count] ==0){
                cell.infoDetailLabel.text = @"-";
            }
            
            [cell setInfoCellDetailBarStyle:InfoCellDetailBarStyleBlue]; 
            break;
        case 2:
            cell.infoTitleLabel.text = @"Arrive By";
            cell.infoDetailLabel.text = [dateFormatter stringFromDate:commute.toArrivalTime];
            [cell setInfoCellDetailBarStyle:InfoCellDetailBarStyleBlue];   
            break;
//        case 3:
//            cell.infoTitleLabel.text = @"Return By";
//            cell.infoDetailLabel.text = [dateFormatter stringFromDate:commute.fromArrivalTime];
//            [cell setInfoCellDetailBarStyle:InfoCellDetailBarStyleBlue]; 
//            break;
            
        case 3:
            cell.infoTitleLabel.text = @"Est. Arrival";
            cell.infoDetailLabel.text = [dateFormatter stringFromDate:estimatedArrivalTime];
            
            [cell setInfoCellDetailBarStyle:InfoCellDetailBarStyleOrange];  
            break;
            
        case 0:
            cell.infoTitleLabel.text = @"Depart In";
            if([routesTemp count] ==0){
                cell.infoDetailLabel.text = @"-";
                cell.clockImageView.alpha = 0;
            }else {
                cell.infoDetailLabel.text = departIn;
                cell.clockImageView.alpha = 1.0;
            }
            if (isTimeTilDepartNegative) {
                [cell setInfoCellDetailBarStyle:InfoCellDetailBarStyleOrange]; 
            } else {
                [cell setInfoCellDetailBarStyle:InfoCellDetailBarStyleBlue]; 
            }
            
            break;

        default:
            cell.infoTitleLabel.text = @"";
            cell.infoDetailLabel.text = @"";
            [cell setInfoCellDetailBarStyle:InfoCellDetailBarStyleNone];
            break;
    }
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *routesTemp = [[commute toRoute] allObjects];

    if (indexPath.row == 0 && routesTemp.count != 0) {
        CountDownViewController *countDownVC = [[CountDownViewController alloc] initWithNibName:@"CountDownViewController" bundle:nil];
        
        NSDate *arriveTime = commute.toArrivalTime;
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:arriveTime];
        
        NSDateComponents *nowComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
        
        NSDate *todayAriveTime = [gregorian dateByAddingComponents:timeComponents toDate:[gregorian dateFromComponents:nowComponents] options:0];
        
        [countDownVC setFinishDate:[NSDate dateWithTimeInterval:-[self averageTime] sinceDate:todayAriveTime]];
        
        [countDownVC setViewWithNavigationViewController:self.parentViewController];
        
        [parentViewController.navigationController presentModalViewController:countDownVC animated:YES];
        [(RootViewController *)parentViewController showCountDownTimer];
    }
    
    if(indexPath.row == 5){
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDelegate showTutorial];
    }
}

- (IBAction)updateCountDown:(id)sender {
    NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:0];
    
    /* // I wanted to update this cell specifically
    InfoTableCell *cell = (InfoTableCell *)[self.tableView cellForRowAtIndexPath:a];
     NSDate *timeToDepart = [commute.toArrivalTime dateByAddingTimeInterval:-(int)[self getAverageTime]];
    NSTimeInterval timeTilDepart = [[NSDate date] timeIntervalSinceDate:timeToDepart];
    //NSLog(@"time to depart - %@",[dateFormatter stringFromDate:timeToDepart]);
    
    NSInteger seconds = (int)timeTilDepart % 60;
    NSInteger minutes = ((int)timeTilDepart / 60) % 60;
    NSInteger hours = ((int)timeTilDepart / 3600);
    
    NSString *hoursString = [NSString stringWithFormat:@"%i",hours];
    NSString *minutesString = [NSString stringWithFormat:@"%i",minutes];
    NSString *secondsString  = [NSString stringWithFormat:@"%i",seconds];
    
    if (hours < 10)
        hoursString = [NSString stringWithFormat:@"0%i",hours];
    if (minutes < 10)
        minutesString = [NSString stringWithFormat:@"0%i",minutes];
    if (seconds < 10)
        secondsString = [NSString stringWithFormat:@"0%i",seconds];
    
    NSString *departIn = [NSString stringWithFormat:@"%@:%@:%@",hoursString,minutesString,secondsString];
    
    NSLog(@"Depart In: %@",departIn);
    
    cell.infoDetailLabel.text = departIn;
    //[cell setNeedsDisplay];
    //[cell reloadInputViews];
    */
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:a, nil] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    [self.view setNeedsDisplay];
   
    [self performSelector:@selector(updateCountDown:) withObject:nil afterDelay:1.0];
   //[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateCountDown:) userInfo:nil repeats:YES];
}




@end
