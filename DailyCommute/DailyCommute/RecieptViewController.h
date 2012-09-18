//
//  RecieptViewController.h
//  DailyCommute
//
//  Created by James Allen on 3/9/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface RecieptViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate,UIAlertViewDelegate>{
    BOOL isEditing;
    UILabel *titleLabel;//Created to show custom fonts
    NSDate *mpStartTime;
    NSDate *mpEndTime;
    NSArray *delayBarTimeArray;//Holds the delay time intervals from the route data.
    //This is calculated once, then used over and over to save data.
    //The even indexes are Normal routes, the odd indexes are delays.
}

@property (strong, nonatomic) Route *route;

@property (strong, nonatomic) IBOutlet UIScrollView *scroller;
@property (strong, nonatomic) IBOutlet UITextField *startTimeField;
@property (strong, nonatomic) IBOutlet UITextField *endTimeField;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel1;//Main label
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel2;//Delay label
@property (strong, nonatomic) IBOutlet UILabel *timeDelayedLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalDistanceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *notesImageView;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *trashButton;
@property (strong, nonatomic) IBOutlet UIImageView *delayBarImage;


-(id)initWithRoute:(Route *)route;
-(void)saveRoute;
-(void)drawRouteBar;
-(IBAction)closeKeyboard:(id)sender;//Dismisses keyboard
-(IBAction)timeChanged:(id)sender;
-(IBAction)changeEditing:(id)sender;

@end
