//
//  InRouteViewController.m
//  DailyCommute
//
//  Created by Weston Catron on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrentRouteViewController.h"
#import "AppDelegate.h"

#define kTimeInterval 320.f
#define kRequiredAccuracy 500.0 //meters
#define kMaxAge 10.0 //seconds

@implementation CurrentRouteViewController

@synthesize context;
@synthesize route;
@synthesize delegate;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (context == nil)
    {context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];}
    
    
    locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;
    locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    currentSpeed = 0;
    [delayTimeLabel setTextColor:[UIColor whiteColor]];
}

- (void)viewDidUnload
{
    mainTimeLabel = nil;
    milisecondTimeLabel = nil;
    delayTimeLabel = nil;
    currentTimeLabel = nil;
    currentTimeLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - methods
-(void)startRoute:(Route *)newRoute{
    route = newRoute;
    routeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];//Update timer label
    //Record location every 10 seconds
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateLocation:) userInfo:nil repeats:YES];
    
    //Account for initial update
    consecutiveDelays = -1;
    delayTime = 0;
    [self updateLocation:nil];
    [locManager startUpdatingLocation];
    
}

-(void)cancelRoute{
    [locManager stopUpdatingLocation];
    [routeTimer invalidate];
    [locationTimer invalidate];
    [context deleteObject:route];
}

-(void)finishRoute:(id)sender{
    [routeTimer invalidate];
    [locationTimer invalidate];
    [self updateLocation:nil];
    [locManager stopUpdatingLocation];
    
    //    [delegate finishRecordingRoute];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish Commute?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Arrive", nil];
    //    [alert show];
}

-(void)updateTime:(id)sender{
    //Timer time
    NSTimeInterval timesinceDate = [route.startTime timeIntervalSinceNow];
    float ftimesinceDate = timesinceDate * -1;
    int minutes = floor(ftimesinceDate/60);
    int seconds = floor(ftimesinceDate - (minutes*60));
    int mili = floor((ftimesinceDate - seconds - (minutes*60)) * 100);
    
    NSString *minutesString = [NSString stringWithFormat:@"%i",minutes];
    NSString *secondsString = [NSString stringWithFormat:@"%i",seconds];
    NSString *miliString = [NSString stringWithFormat:@"%i",mili];
    
    if (minutes < 10)
        minutesString = [NSString stringWithFormat:@"0%i",minutes];
    if (seconds < 10)
        secondsString = [NSString stringWithFormat:@"0%i",seconds];
    if (mili < 10)
        miliString = [NSString stringWithFormat:@"0%i",mili];
    
    //Delay Time
    [mainTimeLabel setText:[NSString stringWithFormat:@"%@:%@",minutesString,secondsString]];
    [milisecondTimeLabel setText:[NSString stringWithFormat:@":%@",miliString]];
    
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //If the user wants to save
    if (buttonIndex!=alertView.cancelButtonIndex) {
        [routeTimer invalidate];
        [locationTimer invalidate];
        [self updateLocation:nil];
        [locManager stopUpdatingLocation];
        [delegate finishRecordingRoute];
    }
}

#pragma mark - CLLocation Manager delegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    NSTimeInterval ageInSeconds = [newLocation.timestamp timeIntervalSinceNow];
    
    //ensure you have an accurate and non-cached reading
    if( newLocation.horizontalAccuracy > kRequiredAccuracy || fabs(ageInSeconds) > kMaxAge )
        return;
    
    //guarantee valid speed
    if(newLocation.speed < 0)
        currentSpeed = 0;
    
    currentSpeed = 2.23693629 * newLocation.speed;
    
    
    
}

-(void)updateLocation:(id)sender{
    
    
    //update location
    //Create thingy
    MovingPoint *movingPoint = [NSEntityDescription insertNewObjectForEntityForName:@"MovingPoint" inManagedObjectContext:context];
    
    //set data
    if(locManager.location!=nil)
        [movingPoint setLocation:locManager.location];
    [movingPoint setTime:[NSDate date]];
    [movingPoint setSpeed:[NSNumber numberWithDouble:currentSpeed]];
    
    //update the delay count
    if(movingPoint.speed.doubleValue < 10)
        consecutiveDelays++;
    else {
        consecutiveDelays = 0;
    }
    
    //if the commute is delayed
    if(consecutiveDelays >= 3){
        delayTime += 10;//add 10 seconds to delay time
        [self animateDelayIncrease];
    }
    
    //Set the initial Time
    if(route.movingPoints.count == 0)
        [route setStartTime:movingPoint.time];
    
    //Set the end time
    [route setEndTime:movingPoint.time];
    
    //Add the new moving point
    [route addMovingPointsObject:movingPoint];
}

-(void)animateDelayIncrease{
    
    if(delayTimeLabel.textColor == [UIColor whiteColor]){
        //Animate the change
        NSUInteger minutes = floor(delayTime/60);
        NSUInteger seconds = floor(delayTime - (minutes*60));
        
        NSString *minutesString = [NSString stringWithFormat:@"%i",minutes];
        NSString *secondsString = [NSString stringWithFormat:@"%i",seconds];
        
        if (minutes < 10)
            minutesString = [NSString stringWithFormat:@"0%i",minutes];
        if (seconds < 10)
            secondsString = [NSString stringWithFormat:@"0%i",seconds];
        
        delayTimeLabel.text = [NSString stringWithFormat:@"%@:%@:00",minutesString,secondsString];
        [delayTimeLabel setTextColor:[UIColor redColor]];
        [self performSelector:@selector(animateDelayIncrease) withObject:nil afterDelay:.1];
    }else{
        //[UIView beginAnimations:@"color back" context:nil];
        //[UIView setAnimationDuration:.5];
        [delayTimeLabel setTextColor:[UIColor whiteColor]];
        //[UIView commitAnimations];
    }
}

-(IBAction)onNotify:(UIButton* )sender{
    
    // Determine if current environment is capable of sending texts.
    if([MFMessageComposeViewController canSendText]){
        
        
        NSString* destination = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentCommuteKey];
        
        // We need to pull the NSDate representing the espected arrival time as a date
        NSDate* etd = [route.startTime dateByAddingTimeInterval:[self getAverageTime]];
        // From the date, all we want is the actual time
        NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"HH:mm";
        NSString* eta = [timeFormatter stringFromDate:etd];
        
//        This will be in the form of: "Hey! I'm using Daily Commute to record my trips and keep track of my life! I'm expecting to get to DESTINATION by ETA. See you soon!"
        NSString* msgBody = [NSString stringWithFormat:@"Hey! I'm using Daily Commute to record my trips and keep track of my life! I'm expecting to get to %@ by %@. See you soon!", destination, eta];
        
        MFMessageComposeViewController* msgComposeView = [[MFMessageComposeViewController alloc] init];
        msgComposeView.body = msgBody;
        msgComposeView.messageComposeDelegate = self;
        
        [self presentModalViewController:msgComposeView animated:YES];
    }
}

// Directly copied from InformationTableViewController.m
- (NSTimeInterval )getAverageTime {
    
    NSArray *routesTemp = [route.toCommute.toRoute allObjects];
    
    NSTimeInterval average = 0;
    
    NSInteger current;
    for (Route *r in routesTemp) {
        current = (NSInteger)[r.endTime timeIntervalSinceDate:r.startTime];
        
        average += current;
    }
    
    if ([routesTemp count] != 0) {
        average = average/[routesTemp count];
    } else {
        average = 0;
    }
    
    return average;
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
