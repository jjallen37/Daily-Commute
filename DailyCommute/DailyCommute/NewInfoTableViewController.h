//
//  NewInfoTableViewController.h
//  DailyCommute
//
//  Created by Harlan Haskins on 9/13/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commute.h"
#import "NewInfoCell.h"

@interface NewInfoTableViewController : UITableViewController {
    NSTimer *timer;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, strong) Commute *commute;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic) NSTimeInterval averageTime;
@property (nonatomic, strong) UIViewController *parentViewController;

-(id) initWithCommute:(Commute *)newCommute;
-(void)updateInfo:(id)sender;

@end
