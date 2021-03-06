//
//  RootViewControllerNewStyleViewController.h
//  DailyCommute
//
//  Created by Harlan Haskins on 9/13/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "NewInfoTableViewController.h"
#import "CurrentRouteViewController.h"
#import "Commute.h"
#import "Route.h"
#import "RecieptViewController.h"
#import "SettingsTableViewController.h"

@interface RootViewControllerNewStyle : UIViewController<CurrentRouteViewControllerDelegate,SKPaymentTransactionObserver, SKProductsRequestDelegate,SKRequestDelegate> {
    IBOutlet UIImageView *backgroundImage;
    BOOL isCommuting;
    BOOL isToCommute; //True if To, false if from
    NSTimer *infoTimer;
    IBOutlet UIImageView *sorryView;
    __weak IBOutlet UILabel *sorryLabel;
    UILabel *titleLabel;//Created to show custom fonts
    //IBOutlet UILabel *commuteLabel; The label at the top with the commute name
    IBOutlet UIView *clockView; //Holds buttons to start commute
    IBOutlet UILabel *timeHoursMinutesLabel; //Big text current time HH:MM
    IBOutlet UILabel *timeTodaysDateLabel; //MM DD, YYYY
    
    IBOutlet UILabel *weatherLabel;
    UIBarButtonItem *cancelBarButton;
    UIBarButtonItem *checkBarButton;
    
    IBOutlet UIButton *toCommuteButton;
    
    IBOutlet UITableView *informationTableView;
    
    
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
-(Commute *)currentCommute;
@property (strong, nonatomic) Route *currentRoute;

@property (strong, nonatomic) CurrentRouteViewController *currentRouteViewController;
@property (nonatomic, strong) RecieptViewController *currentRouteReceipt;

@property (strong, nonatomic) NewInfoTableViewController *informationTableViewController;


@property (strong, nonatomic) IBOutlet UITableView *informationTableView;
@property (nonatomic, strong) UIView *statsView;


//Updates information on screen
-(void)updateTime:(id)sender;

//Starts a commute, called when the "to" or "return" button is pressed.
-(IBAction)saveRoute:(id)sender;

//Cancels the route and deletes unused data
-(void)cancelRoute:(id)sender;

//Finishes a commute and returns to the home screen
-(void)saveRoute:(id)sender;

//Returns to the main screen
-(void)showMainScreen:(id)sender;
-(void)showCountDownTimer;
-(IBAction)purchaseInApp:(id)sender;

@end
