//
//  RecieptViewController.m
//  DailyCommute
//
//  Created by James Allen on 3/9/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "RecieptViewController.h"
#import "AppDelegate.h"


@implementation RecieptViewController

@synthesize route;

@synthesize scroller;
@synthesize startTimeField;
@synthesize endTimeField;
@synthesize totalTimeLabel1;
@synthesize totalTimeLabel2;
@synthesize timeDelayedLabel;
@synthesize totalDistanceLabel;
@synthesize notesImageView;
@synthesize notesTextView;
@synthesize timePicker;
@synthesize editButton, trashButton;
@synthesize delayBarImage;


-(id)initWithRoute:(Route *)newRoute{
    route = newRoute;
    
    return [self init];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    isEditing = TRUE;
    [self changeEditing:nil];
    
    self.title = self.route.toCommute.name;
    
    //Change Keyboard views
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"hh:mm a"];
    
    startTimeField.inputView = timePicker;
    startTimeField.text = [formatter stringFromDate:route.startTime];
    
    endTimeField.inputView = timePicker;    
    endTimeField.text = [formatter stringFromDate:route.endTime];
    
    
    //Make notes view look purty
    UIImageView *backgroundimage = [[UIImageView alloc] initWithFrame: CGRectMake(-15, -100,310, 900)];
    backgroundimage.image = [UIImage imageNamed:@"notes.png"];
    self.notesTextView.contentSize = CGSizeMake(280, 700);
    self.notesTextView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.notesTextView addSubview:backgroundimage];
    [self.notesTextView sendSubviewToBack:backgroundimage];
    
    if (![route.notes isEqualToString:@""]) {
        [self.notesTextView setText:route.notes];
    }
    
    //Make sure array is sorted by time, update various helper variables
    NSSortDescriptor *byTime = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:byTime, nil];
    NSMutableArray *movingPoints = [[NSMutableArray alloc] initWithArray:[route.movingPoints sortedArrayUsingDescriptors:sortDescriptors]];
    mpStartTime = ((MovingPoint *)[movingPoints objectAtIndex:0]).time;
    mpEndTime = ((MovingPoint *)[movingPoints lastObject]).time;
    
    NSLog(@"1st point - %@",[movingPoints objectAtIndex:0]);
    NSLog(@"last point - %@",movingPoints.lastObject);

    //Total distance
    double miles = 0.000621371192*[((MovingPoint *)[movingPoints objectAtIndex:0]).location distanceFromLocation:((MovingPoint *)movingPoints.lastObject).location];
    
    if (miles > 1500) {
        totalDistanceLabel.text = @"0 Miles";
    }else{
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        [numFormatter setMaximumFractionDigits:1];
        [numFormatter setRoundingMode: NSNumberFormatterRoundDown];
        totalDistanceLabel.text= [NSString stringWithFormat:@"%@ Miles",[numFormatter stringFromNumber:[NSNumber numberWithFloat:miles]]];
    }
    
    //Allow user to close keyboards
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    [notesImageView addGestureRecognizer:gr];
    
    
    
    //Calculate delaybar time schedule
    NSMutableArray *tempTimeArray = [[NSMutableArray alloc] init];
    [tempTimeArray addObject:[NSNumber numberWithDouble:0.0]];//Empty time interval
    NSUInteger consecutiveDelays = 0;
    
    ////Initiate delay array
    for(int i=0; i<movingPoints.count-1; i++){
        MovingPoint *mp1 = (MovingPoint *)[movingPoints objectAtIndex:i];
        MovingPoint *mp2 = (MovingPoint *)[movingPoints objectAtIndex:i+1];
        
        if(mp2.speed.doubleValue < 10.0){//mph
            consecutiveDelays++;
        }else {
            consecutiveDelays=0;
        }
        
        if(consecutiveDelays == 3){
            [tempTimeArray addObject:[NSNumber numberWithDouble:0.0]];//Empty time interval
        }
        
        NSTimeInterval ti = ((NSNumber *)[tempTimeArray lastObject]).doubleValue;
        ti+=[mp2.time timeIntervalSinceDate:mp1.time];
        [tempTimeArray replaceObjectAtIndex:tempTimeArray.count-1 withObject:[NSNumber numberWithDouble:ti]];
    }
    
    delayBarTimeArray = tempTimeArray;
    //Update labels and delay bar
    [self timeChanged:timePicker];    
}

- (void)viewDidUnload
{
    [self setTotalDistanceLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Methods

-(void)saveRoute{
    //Close Keyboards
    [self closeKeyboard:nil];
    
    //Save the context
    NSManagedObjectContext *context;
    if (context == nil) 
    {context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];}
    NSError *error;
    [context save:&error];
}

-(void)drawRouteBar{//Make the delay bar
    //Clear the bar
    for(UIView *subView in delayBarImage.subviews)
        [subView removeFromSuperview];
    
    NSTimeInterval totalTime = [route.endTime timeIntervalSinceDate:route.startTime];
    
    /*
     //If the data isn't even on the screen.
     if(mpStartTime route.endTime || mpEndTime < route.startTime){
     return;
     }
     */
    
    double PIXELS_PER_SEC = 310/totalTime;//width of the bar
    int startIndex = [route.startTime timeIntervalSinceDate:mpStartTime]*PIXELS_PER_SEC;
    int endIndex = [mpEndTime timeIntervalSinceDate:route.endTime]*PIXELS_PER_SEC + 310;
    
    if(endIndex <= 0 || startIndex >=310)
        return;
    
    int currentIndex = startIndex;
    BOOL delay = NO;

    for(NSNumber *ti in delayBarTimeArray){
        
        int width = ti.doubleValue * PIXELS_PER_SEC;
        
        
        //Correct routes on the edge of being visible.
        if(currentIndex<0 && currentIndex+width>=0){
            currentIndex = 0;
            width = width - currentIndex;
        }else if(currentIndex+width>endIndex){
            width = endIndex-currentIndex;
        }
        
        UIImageView *delayBarSegmentView = [[UIImageView alloc] initWithFrame:
                                            CGRectMake(currentIndex, 0,width,22)];
        
        
        //Set color
        NSString *segmentImageString;
        if(delay){
            segmentImageString = [NSString stringWithFormat:@"TripbarGrey.png"];
        }else {
            segmentImageString = [NSString stringWithFormat:@"TripBarNormal.png"];
        }
        
        [delayBarSegmentView setImage:[UIImage imageNamed:segmentImageString]];
        [delayBarImage addSubview:delayBarSegmentView];
        delay = !delay;
        
        currentIndex+=width;
    }
}

-(IBAction)closeKeyboard:(id)sender{
    if(startTimeField.isFirstResponder){
        [startTimeField resignFirstResponder];
    }else if(endTimeField.isFirstResponder){
        [endTimeField resignFirstResponder];
    }else if(notesTextView.isFirstResponder){
        [notesTextView resignFirstResponder];
        [scroller setContentOffset:CGPointMake(0, 0) animated:YES];
        self.notesTextView.contentSize = CGSizeMake(280, 700);
        //[self.notesTextView setContentOffset:CGPointMake(-14, 0) animated:YES];
        
    }
}

//Date Picker
-(IBAction)timeChanged:(id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"hh:mm a"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    
    if(startTimeField.isFirstResponder){  
        NSDateComponents *stComp = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:route.startTime];
        NSDateComponents *ptComp = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:timePicker.date];
        NSTimeInterval ti = ([ptComp hour]-[stComp hour])*3600+([ptComp minute]-[stComp minute])*60;
        
        NSDate *newDate = [route.startTime dateByAddingTimeInterval:ti];    
        [route setStartTime:newDate];
        startTimeField.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:route.startTime]];    
    }else if(endTimeField.isFirstResponder){
        NSDateComponents *stComp = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:route.endTime];
        NSDateComponents *ptComp = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:timePicker.date];
        NSTimeInterval ti = ([ptComp hour]-[stComp hour])*3600+([ptComp minute]-[stComp minute])*60;
        
        NSDate *newDate = [route.endTime dateByAddingTimeInterval:ti];    
        [route setEndTime:newDate];
        endTimeField.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:route.endTime]];
    }
    
    
    NSInteger ti = (NSInteger)[route.endTime timeIntervalSinceDate:route.startTime];
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    totalTimeLabel1.text = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds]; 
    totalTimeLabel2.text = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
    [self drawRouteBar];
}

-(IBAction)changeEditing:(id)sender{
    
    if(isEditing){
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeEditing:)];
    }else{

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeEditing:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleDone target:self action:@selector(promptDelete:)];
    }
    
    [UIView beginAnimations:@"derp" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.4];
    if(isEditing){
        isEditing = FALSE;
        [startTimeField setEnabled:NO];
        [endTimeField setEnabled:NO];
        startTimeField.textAlignment = UITextAlignmentRight; 
        endTimeField.textAlignment = UITextAlignmentRight;
        startTimeField.background = nil;
        endTimeField.background = nil;
    }else{
        
        isEditing = TRUE;
        [startTimeField setEnabled:YES];
        [endTimeField setEnabled:YES];
        startTimeField.textAlignment = UITextAlignmentCenter; 
        endTimeField.textAlignment = UITextAlignmentCenter; 
        startTimeField.background = [UIImage imageNamed:@"editbg.png"];
        endTimeField.background = [UIImage imageNamed:@"editbg.png"];
    }
    [UIView commitAnimations];
    
    
}
#pragma mark - Text Field View Delegates
//Sets the pickers initial time
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == startTimeField){
        [timePicker setDate:route.startTime];
        [timePicker setMinimumDate:nil];
        [timePicker setMaximumDate:route.endTime];
    }else if(textField == endTimeField){
        [timePicker setDate:route.endTime];
        [timePicker setMinimumDate:route.startTime];
        [timePicker setMaximumDate:nil];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [scroller setContentOffset:CGPointMake(0, 140) animated:YES];
    //[textView setContentOffset:CGPointMake(-14, 0) animated:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    [route setNotes:textView.text];
}


//Corrects notes text view scrolling.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView==notesTextView){
        if(scrollView.contentOffset.x != -15)
            [scrollView setContentOffset:CGPointMake(-15, scrollView.contentOffset.y)];
        if(scrollView.contentOffset.y > 300)
            [scrollView setContentOffset:CGPointMake(-15, 300)];
    }
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(notesTextView.isFirstResponder){
        UITouch *touch = [touches anyObject];
        CGPoint loc = [touch locationInView:notesTextView];
        if(loc.y < 0)
            [notesTextView resignFirstResponder];
    }
}

-(IBAction)promptDelete:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Remove Route"
                          message: @"Do you want to delete this route?"
                          delegate: self
                          cancelButtonTitle:@"NO"
                          otherButtonTitles:@"YES",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex) {
	}else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        NSManagedObjectContext *context;
        if (context == nil) 
        {context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];}
        [context deleteObject:route];
        NSError *error;
        [context save:&error];
	}
}

@end
