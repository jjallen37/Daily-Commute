//
//  CountDownViewController.h
//  DailyCommute
//
//  Created by Weston Catron on 4/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountDownViewController : UIViewController { 
    UILabel *countDownLabel;
    UILabel *currentTimeLabel;
    UILabel *statusLabel;
    NSDate *finishDate;
    
    IBOutlet UIImageView *backgroundImage;
    
}

@property (nonatomic, strong) NSDate *finishDate;
@property (nonatomic, strong) UIViewController *viewWithNavigationViewController;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImage;

-(IBAction)closeView:(id)sender;

@end
