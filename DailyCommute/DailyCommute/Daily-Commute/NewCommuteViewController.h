//
//  NewCommuteModalNavigationController.h
//  DailyCommute
//
//  Created by James Allen on 3/28/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commute.h"
#import "CommuteSettingsViewController.h"
#import "CustomNavigationBar.h"

@protocol NewCommuteModalDelegate <NSObject>

-(void)acceptCommute;
-(void)refuteCommute;
@end

@interface NewCommuteViewController : UIViewController{
    IBOutlet UITableView *settingsTV;
    IBOutlet UINavigationItem *navItem;
}

@property (nonatomic, assign) id<NewCommuteModalDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) Commute *commute;
@property (strong, nonatomic) CommuteSettingsViewController *settingsTVC;

-(IBAction)acceptCommute:(id)sender;//Saves new Commute
-(IBAction)refuteCommute:(id)sender;//Cancels new Commute

@end
