//
//  SettingsCell.m
//  DailyCommute
//
//  Created by James Allen on 3/31/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "SettingsCell.h"

@implementation SettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat xPosition = 20.0f; //Default text position

    if (!self.editing){

        CGRect textLabelFrame = self.textLabel.frame;
        textLabelFrame.origin.x = xPosition;
        self.textLabel.frame = CGRectMake(textLabelFrame.origin.x, textLabelFrame.origin.y, textLabelFrame.size.width-20.0f, textLabelFrame.size.height);
        

    }else{
        CGRect textLabelFrame = self.textLabel.frame;
        textLabelFrame.origin.x = xPosition;
        self.textLabel.frame = textLabelFrame;
        self.detailTextLabel.text = @"Current";
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if(selected){
        if (isON) {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
            self.accessoryType = UITableViewCellAccessoryNone;
        }    
        isON = TRUE;
    }else {
        isON = FALSE;
    }
}

@end
