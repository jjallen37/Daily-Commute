//
//  NewInfoCell.m
//  DailyCommute
//
//  Created by Harlan Haskins on 9/13/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "NewInfoCell.h"

@implementation NewInfoCell

@synthesize infoDetailLabel;
@synthesize infoTitleLabel;
@synthesize infoDetailLabelBackgroundImage;
@synthesize departInImageView;
@synthesize clockImageView;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!self) {
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setInfoCellDetailBarStyle:(InfoCellDetailBarStyle)style{
    
    if (style == NewInfoCellDetailBarStyleDepartIn){
        [self.infoDetailLabel setBounds:CGRectMake(243, 7, 77, 35)];
        [infoDetailLabelBackgroundImage setHidden:YES];
        [departInImageView setHidden:NO];
        [clockImageView setHidden:NO];
        self.infoDetailLabel.textColor = [UIColor whiteColor];    }
    
    else {
        [self.infoDetailLabel setBounds:CGRectMake(236, 7, 77, 35)];
        [infoDetailLabelBackgroundImage setHidden:NO];
        [departInImageView setHidden:YES];
        [clockImageView setHidden:YES];
    }
}

@end
