//
//  SettingsViewController.h
//  Daily-Commute
//
//  Created by James Allen on 9/1/12.
//  Copyright (c) 2012 James Allen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewCommuteViewController.h"

@class Commute;
@interface SettingsViewController : UITableViewController<NewCommuteModalDelegate>{
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

