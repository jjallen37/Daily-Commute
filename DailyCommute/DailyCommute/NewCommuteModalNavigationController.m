//
//  NewCommuteModalNavigationController.m
//  DailyCommute
//
//  Created by James Allen on 3/28/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "NewCommuteModalNavigationController.h"
#import "AppDelegate.h"
#import "Commute.h"

@implementation NewCommuteModalNavigationController


@synthesize context;
@synthesize commute;
@synthesize settingsTVC;
@synthesize delegate;

-(void)viewDidLoad{
    
    //Load the context if needed
    if (context == nil) 
    { 
        context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    }
    
    settingsTVC = [[CommuteSettingsTableViewController alloc] initWithCommute:commute];
    settingsTVC.managedObjectContext = context;
    settingsTV.delegate = settingsTVC;
    settingsTV.dataSource = settingsTVC;
    
    //Font
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:22];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.shadowOffset = CGSizeMake(0,2);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor =[UIColor whiteColor];
	titleLabel.text = @"New Commute";	
	navItem.titleView = titleLabel;	
    
    [settingsTV setEditing:YES animated:YES];
}


-(IBAction)acceptCommute:(id)sender{
    [settingsTVC saveCommute];
    if(commute.name.length == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commute Name" message:@"You must provide a destination." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:commute.name forKey:kCurrentCommuteKey];
        [delegate acceptCommute];
    }
}

//Saves new Commute
-(IBAction)refuteCommute:(id)sender{
    [delegate refuteCommute];
}//Cancels new Commute


@end
