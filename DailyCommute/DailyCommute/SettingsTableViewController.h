//
//  SettingsTableViewController.h
//  DailyCommute
//
//  Created by James Allen on 3/26/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NewCommuteModalNavigationController.h"
#import "CommuteSettingsTableViewController.h"
#import "TipsViewController.h"
#import "Commute.h"

@interface SettingsTableViewController : UITableViewController<NewCommuteModalDelegate, UIAlertViewDelegate>{
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *checkButton;
    BOOL isEditing;
    Commute *aNewCommute;
    NSUserDefaults *userDefaults;
}


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *commuteArray;

-(IBAction)presentNewCommuteView:(id)sender;//Presents new Commute screen.
-(Commute *)currentCommute;
@end
