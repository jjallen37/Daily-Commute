//
//  CountDownViewController.m
//  DailyCommute
//
//  Created by Weston Catron on 4/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "CountDownViewController.h"

@interface CountDownViewController ()

@end

@implementation CountDownViewController

@synthesize finishDate,viewWithNavigationViewController;
@synthesize backgroundImage;

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
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
    
    [backgroundImage setImage:[UIImage imageNamed:@"timer_green.png"]];
    
    countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(-80, 150, 460, 200)];
    [countDownLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:110]];
    [countDownLabel setShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.75]];
    [countDownLabel setShadowOffset:CGSizeMake(0, 3)];
    [countDownLabel setBackgroundColor:[UIColor clearColor]];
    [countDownLabel setTextColor:[UIColor whiteColor]];
    countDownLabel.transform = transform;
    [countDownLabel setText:@"00:00:00"];
    
    [self.view addSubview:countDownLabel];
    
    currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, 180, 40)];
    [currentTimeLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:40]];
    [currentTimeLabel setShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.75]];
    [currentTimeLabel setShadowOffset:CGSizeMake(0, 3)];
    [currentTimeLabel setBackgroundColor:[UIColor clearColor]];
    [currentTimeLabel setTextColor:[UIColor whiteColor]];
    [currentTimeLabel setTransform:transform];
    [currentTimeLabel setText:@"00:00 AM"];
    
    [self.view addSubview:currentTimeLabel];
    
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 95, 180, 40)];
    [statusLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:20]];
    [statusLabel setShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.75]];
    [statusLabel setShadowOffset:CGSizeMake(0, 3)];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    [statusLabel setTextColor:[UIColor whiteColor]];
    [statusLabel setTransform:transform];
    [statusLabel setText:@"YOU ARE LATE!"];
    
    [self.view addSubview:statusLabel];
    
    statusLabel.alpha = 0.0;
    
    //finishDate = [NSDate dateWithTimeIntervalSinceNow:295092];
    
    [self performSelector:@selector(updateCountDown:) withObject:nil afterDelay:1.0];
    
    UIButton *hideButton = [[UIButton alloc] initWithFrame:CGRectMake(255, 10, 80, 40)];
    [hideButton setBackgroundColor:[UIColor clearColor]];
    //[hideButton setTitle:@"Back" forState:UIControlStateNormal];
    [hideButton.titleLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:20]];
    [hideButton setTransform:transform];
    [hideButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hideButton];
        
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)updateCountDown:(id)sender {
    NSTimeInterval timeTilDepart = -[[NSDate date] timeIntervalSinceDate:finishDate];
    
    [backgroundImage setImage:[UIImage imageNamed:@"timer_green.png"]];
    
    //NSLog(@"TimeTilDepart: %f",timeTilDepart);
    statusLabel.alpha = 0.0;
    if (timeTilDepart < 0) {
        timeTilDepart = -timeTilDepart;
        
        [backgroundImage setImage:[UIImage imageNamed:@"timer_red.png"]];
        statusLabel.alpha = 1.0;
    } else if (timeTilDepart < 300) {
        [backgroundImage setImage:[UIImage imageNamed:@"timer_yellow.png"]];
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Current time
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];
    currentTimeLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    [countDownLabel setText:departIn];
    [self performSelector:@selector(updateCountDown:) withObject:nil afterDelay:1.0];
}

-(IBAction)closeView:(id)sender {
//    NSLog(@"CloseView");
    [viewWithNavigationViewController.navigationController dismissModalViewControllerAnimated:YES];
}

@end
