//
//  CommuteSettingsViewControler.h
//  DailyCommute
//
//  Created by James Allen on 8/3/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commute.h"
#import "EditableCell.h"


@interface CommuteSettingsViewController : UITableViewController<UITextFieldDelegate>{
    //Handles Date Picker Interactions
    NSDateFormatter *dateFormatter;
    IBOutlet UIDatePicker *datePicker;
    
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Commute *currentCommute;

-(id)initWithCommute:(Commute *)commute;
-(void)saveCommute;
-(void)hideKeyboard;

@end
