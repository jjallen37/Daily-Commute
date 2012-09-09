//
//  EditableCell.m
//  DailyCommute
//
//  Created by James Allen on 3/29/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "EditableCell.h"

@implementation EditableCell

@synthesize textField;
@synthesize titleLabel;
@synthesize timePicker;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	// The user can only edit the text field when in editing mode.
    [super setEditing:editing animated:animated];
	textField.enabled = editing;
}


-(void)setInputViewStyle:(InputViewStyle)viewStyle{
    if(viewStyle == InputViewStyleTimePicker){
        textField.inputView = timePicker;
        textField.enabled = NO;
    }else{
        textField.inputView = nil;
    }
}

-(IBAction)datePickerChanged:(id)sender{
    //Date Formatter
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];//08:37 PM
    
    textField.text = [dateFormatter stringFromDate:timePicker.date];
}
@end
