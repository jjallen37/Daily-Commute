//
//  RootViewController.m
//  DailyCommute
//
//  Created by Weston Catron on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kinAppIdentifier @"dailycommute.valleyrocket.com.dcgopro"

#import "RootViewController.h"
#import "AppDelegate.h"
#import "InAppPurchaseManager.h"

@implementation RootViewController

@synthesize managedObjectContext;
@synthesize currentRoute;
@synthesize currentRouteViewController;
@synthesize currentRouteReceipt;
@synthesize informationTableViewController;
@synthesize informationTableView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];  
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    //Initilize objects
    isCommuting = NO;
    cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelRoute:)];
    checkBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishRecordingRoute)];
    
    //Keep updating todays date information
    [self performSelector:@selector(updateTime:) withObject:nil afterDelay:1.0];
    infoTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [infoTimer fire];
    
    UIBarButtonItem *_backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = _backButton;
    
    //Stats view
    /*statsViewController = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil];
    [statsViewController setDelegate:self];
    statsView = statsViewController.view;
    [self.view addSubview:statsView];  
    [statsView setFrame:CGRectMake(0, 310, statsView.frame.size.width, statsView.frame.size.height)];
    */
    
    //Information Table
    informationTableViewController = [[InformationTableViewController alloc] initWithCommute:self.currentCommute];
    [informationTableViewController setTableView:informationTableView];
    [informationTableViewController setParentViewController:self];
    informationTableView.delegate = informationTableViewController;
    informationTableView.dataSource = informationTableViewController;
        
    ////Adjust Fonts
    [timeHoursMinutesLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:60]];
    [timeTodaysDateLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:17]];
    [weatherLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:17]];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:24];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.shadowOffset = CGSizeMake(2,2);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor =[UIColor whiteColor];
	titleLabel.text = self.title;
    
	self.navigationItem.titleView = titleLabel;
    
    backgroundImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    //Show main View
    [self showMainScreen:nil];
    [self.view setNeedsDisplay];
}

- (void)viewDidUnload
{
    weatherLabel = nil;
    backgroundImage = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) showCountDownTimer {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.currentCommute == nil){
        self.title = @"";
        titleLabel.text = self.title;	
//        [self showSettingsScreen:nil];
    }else {
        self.title = self.currentCommute.name;
        titleLabel.text = self.title;	
    }
    
    [informationTableViewController updateInfo:self.currentCommute];
    [informationTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
//    [self.statsViewController hideStatsView];
}

#pragma mark - methods

-(Commute *)currentCommute{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *commuteName = [userDefaults stringForKey:kCurrentCommuteKey];
    //Load the context if needed
    if (managedObjectContext == nil) 
    { 
        managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    }
    
    //Find the commute with the name of text label
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",commuteName]; 
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Commute"
                                              inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];   
    
    if(objects == nil){
        NSLog(@"Error in core data");
    }
    //If the commute doesnt exist, make it
    if([objects count] == 0){
        return nil;
    }else{
        return [objects objectAtIndex:0];
    }
    
}

//Updates information on screen
-(void)updateTime:(id)sender{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //Todays Date
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    timeTodaysDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    //Current time
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];
    timeHoursMinutesLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    //Keep info correct.
    
    NSManagedObjectContext *context = managedObjectContext;
    NSPredicate *predicate;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Route"];
    predicate = [NSPredicate predicateWithFormat:@"toCommute == %@ || fromCommute == %@", [self currentCommute],[self currentCommute]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
    
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *routesTemp = [context executeFetchRequest:request error:&error];  
    
    
    int average = 0;
    
    NSInteger current;
    for (Route *route in routesTemp) {
        current = (NSInteger)[route.endTime timeIntervalSinceDate:route.startTime];
        average += current;
    }
    
    if ([routesTemp count] != 0) {
        average = average/[routesTemp count];
    }
    
    informationTableViewController.averageTime = average;
    [informationTableViewController.tableView reloadData];
    
    
    [self performSelector:@selector(updateTime:) withObject:nil afterDelay:1.0];

}

- (IBAction)startRoute:(UIButton *)sender {
    isCommuting = YES;
    if(sender.tag==0)//To Commute
        isToCommute = TRUE;
    else//From commute
        isToCommute = FALSE;
    
    //Create the route
    currentRoute = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:managedObjectContext];
    
    //Set up a new current Route view.
    currentRouteViewController = [[CurrentRouteViewController alloc] initWithNibName:@"CurrentRouteViewController" bundle:nil];
    currentRouteViewController.delegate = self;

    [currentRouteViewController.view setFrame:CGRectMake(0, 0, 320, 140)];
    [currentRouteViewController.view setAlpha:0];
    [currentRouteViewController startRoute:currentRoute];
    [self.view addSubview:currentRouteViewController.view];
    
    //Change Views
    [self.navigationItem setLeftBarButtonItem:cancelBarButton animated:YES];
    [self.navigationItem setRightBarButtonItem:checkBarButton animated:YES];
    [UIView beginAnimations:@"inRouteAnimation" context:nil];
    [UIView setAnimationDuration:.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    [clockView setAlpha:0];
    [currentRouteViewController.view setAlpha:1];
    [UIView commitAnimations];
    
}

//Cancels the route and deletes unused data
-(void)cancelRoute:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel Commute" message:@"Are you sure you want to cancel this commute?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
}


- (void)approvedCancelRoute {
    isCommuting = NO;
    if(currentRouteViewController!=nil)
        [currentRouteViewController cancelRoute];//Stop timers, delete route
    if(currentRouteReceipt!=nil){
        [currentRouteReceipt closeKeyboard:nil];
    }
    [self showMainScreen:self];//Show main screen.
    currentRouteViewController = nil;
    currentRouteReceipt = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

//Finishes a commute and returns to the home screen
-(void)saveRoute:(id)sender{
    isCommuting = NO;
    //Prevent multiple commutes per day.
    if(isToCommute == FALSE){
        //[fromCommuteButton setEnabled:NO];
        [self.currentCommute addFromRouteObject:currentRoute];
    }else{
        [self.currentCommute addToRouteObject:currentRoute];
    }
    //[toCommuteButton setEnabled:NO];
    [currentRouteReceipt saveRoute];
    //Close keyboards, Save the context

//    [statsViewController refreshTopStats];
    
    [self showMainScreen:sender];
}

//Returns to the main screen
-(void)showMainScreen:(id)sender{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [UIView beginAnimations:@"mainScreenAnimation" context:nil];
    [UIView setAnimationDuration:.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [clockView setAlpha:1];
    [informationTableView setAlpha:1];
    [currentRouteViewController.view setAlpha:0];
//    [currentRouteReceipt.view setAlpha:0];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"isProUpgradePurchased"]) {
//        UIBarButtonItem *goPro = [[UIBarButtonItem alloc] initWithCustomView:goProBarButton];
        
//        [self.navigationItem setRightBarButtonItem:goPro];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    [UIView commitAnimations];
}

#pragma mark - In Route Delegate

//Called when the inRouteVC finishes the commute. 
-(void)finishRecordingRoute{
    //Create the receipt view to be shown
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish Commute?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Arrive", nil];
    alert.tag = 37;
    [alert show];
    
//    //Finish recording
//    [currentRouteViewController finishRoute:nil];
//    
//    //Create a receipt and present it
//    currentRouteReceipt = [[RecieptViewController alloc] initWithRoute:currentRoute];
//    [self.navigationController pushViewController:currentRouteReceipt animated:YES];
//    [self showMainScreen:nil];
//    
//    [self saveRoute:nil];
    
    
//    [currentRouteReceipt.view setFrame:CGRectMake(0, 0, 320, 343)];
//    [currentRouteReceipt.view setAlpha:0];
//    [self.view addSubview:currentRouteReceipt.view];
//    
//    //Show it and hide other things.
//    [self.navigationItem setRightBarButtonItem:checkBarButton];
//    [UIView beginAnimations:@"recieptAnimation" context:nil];
//    [UIView setAnimationDuration:.7];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [clockView setAlpha:0];
//    [informationTableView setAlpha:0];
//    [currentRouteViewController.view setAlpha:0];
//    [currentRouteReceipt.view setAlpha:1];
//    [UIView commitAnimations];
}

//-(IBAction)showSettingsScreen:(id)sender{
//    SettingsTableViewController *settingsTVC = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    BOOL anim = YES;
//    if(self.currentCommute==nil)
//        anim=NO;
//    [self.navigationController pushViewController:settingsTVC animated:anim];
//}

#pragma mark - Stats View Delegate

-(BOOL)isInRoute {
    return isCommuting;
}

//-(void)showStatsView {
//    [UIView animateWithDuration:.7
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
//                     animations:^{[statsView setFrame:CGRectMake(0, -4, statsView.frame.size.width, statsView.frame.size.height)];}
//                     completion:nil];
//    
//}
//-(void)hideStatsView {
//    [UIView animateWithDuration:.7
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
//                     animations:^{[statsView setFrame:CGRectMake(0, 310, statsView.frame.size.width, statsView.frame.size.height)];}
//                     completion:nil];
//}
//
//- (IBAction)toggleStatMapAndGraph:(id)sender {
//    
//}

- (void)showExAndCheckButtons {
    [self.navigationItem setLeftBarButtonItem:cancelBarButton];
    [self.navigationItem setRightBarButtonItem:checkBarButton];
}

-(Commute *)getCurrentCommute {
    return self.currentCommute;
}
         

//- (void)showCancelButton {
//    [UIView animateWithDuration:.7
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
//                     animations:^{[cancelBarButton setAlpha:1];}
//                     completion:nil];
//    
//    [UIView animateWithDuration:.7
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
//                     animations:^{[checkBarButton setAlpha:1];}
//                     completion:nil];
//}
//
//- (void)hideCancelButton {
//    [UIView animateWithDuration:.7
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
//                     animations:^{[cancelBarButton setAlpha:0];}
//                     completion:nil];
//    [UIView animateWithDuration:.7
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveEaseInOut
//                     animations:^{[checkBarButton setAlpha:0];}
//                     completion:nil];
//    
//    
//    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:settingsBarButton]  animated:YES];
//    
//    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"isProUpgradePurchased"]) {
//        UIBarButtonItem *goPro = [[UIBarButtonItem alloc] initWithCustomView:goProBarButton];
//        [self.navigationItem setRightBarButtonItem:goPro];
//    } else {
//        [self.navigationItem setRightBarButtonItem:nil];
//    }
//}
//
//- (void)showCountDownTimer {
//    [self.statsViewController disappearStatsView];
//}

#pragma mark - In App
-(IBAction)purchaseInApp:(id)sender{
    NSLog(@"Purchase in app");
    NSSet *productIdentifiers = [NSSet setWithObject:kinAppIdentifier];
    SKProductsRequest* request = [[SKProductsRequest alloc]
                                  initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Product request did recieve a response");
    for(SKProduct* thing in response.products){
        NSLog(@"Title:%@",thing.localizedTitle);
        NSLog(@"Description:%@",thing.localizedDescription);
        NSLog(@"ID%@",thing.productIdentifier);
    }
    for(id thing in response.invalidProductIdentifiers)
        NSLog(@"Invalid: %@",thing);
    if(response.products.count!=0){//if its valid, make the payment.
        SKProduct *product = [response.products objectAtIndex:0];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Failed with error!");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)
transactions{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failed Transaction");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"recordTransaction");
    if ([transaction.payment.productIdentifier isEqualToString:kinAppIdentifier])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)provideContent:(NSString *)productId
{
    NSLog(@"provideContent");
    if ([productId isEqualToString:kinAppIdentifier])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self viewDidLoad];
        [self showMainScreen:self];
    }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    NSLog(@"finish Transaction");
    
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InAppPurchaseManagerTransactionSucceededNotification" object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InAppPurchaseManagerTransactionFailedNotification" object:self userInfo:userInfo];
    }
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //If the user wants to save
    if(alertView.tag==37){//Finish the route
        if (buttonIndex!=alertView.cancelButtonIndex) {
            //Finish recording
            [currentRouteViewController finishRoute:nil];
            [self saveRoute:nil];

            //Create a receipt and present it
            currentRouteReceipt = [[RecieptViewController alloc] initWithRoute:currentRoute];
            [self.navigationController pushViewController:currentRouteReceipt animated:YES];
            [self showMainScreen:nil];
            
        }

    }else if (buttonIndex!=alertView.cancelButtonIndex) {
        [self approvedCancelRoute];
    }
}

@end
