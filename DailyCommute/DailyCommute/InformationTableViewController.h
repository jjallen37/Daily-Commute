//
//  InformationTableViewController.h
//  DailyCommute
//
//  Created by Weston Catron on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commute.h"
#import "InfoTableCell.h"


@interface InformationTableViewController : UITableViewController{
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
