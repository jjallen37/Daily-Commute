//
//  EditableCell.h
//  DailyCommute
//
//  Created by James Allen on 3/29/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    InputViewStyleNone,
    InputViewStyleTimePicker
}InputViewStyle;
@interface EditableCell : UITableViewCell{
    UITextField *textField;
    UILabel *titleLabel;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIDatePicker *timePicker;

-(void)setInputViewStyle:(InputViewStyle)viewStyle;
-(IBAction)datePickerChanged:(id)sender;

@end
