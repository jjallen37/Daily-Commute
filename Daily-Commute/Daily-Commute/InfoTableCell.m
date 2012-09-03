//
//  InfoTableCell.m
//  DailyCommute
//
//  Created by James Allen on 3/20/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "InfoTableCell.h"

@implementation InfoTableCell

@synthesize infoDetailLabel;
@synthesize infoTitleLabel;
@synthesize infoDetailLabelBackgroundImage;
@synthesize clockImageView;

-(void)setInfoCellDetailBarStyle:(InfoCellDetailBarStyle)style{
    
    if(style == InfoCellDetailBarStyleBlue){
        [infoDetailLabelBackgroundImage setImage:[UIImage imageNamed:@"bluetimebg.png"]];
        
        [infoDetailLabel setTextColor:[UIColor colorWithRed:24.0/255.0 green:43.0/255.0 blue:71.0/255.0 alpha:1.0]];
        [infoDetailLabel setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
        
        [infoDetailLabelBackgroundImage setHidden:NO];
        [infoDetailLabel setHidden:NO];
        if (style == InfoCellDetailBarStyleTime) {
            [clockImageView setAlpha:1.0];
        }
    }else if(style == InfoCellDetailBarStyleOrange){
        [infoDetailLabelBackgroundImage setImage:[UIImage imageNamed:@"orangetimebg.png"]];
        
        [infoDetailLabel setTextColor:[UIColor colorWithRed:51.0/255.0 green:28.0/255.0 blue:4.0/255.0 alpha:1.0]];
        [infoDetailLabel setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
        
        [infoDetailLabelBackgroundImage setHidden:NO];
        [infoDetailLabel setHidden:NO];
    }else if(style == InfoCellDetailBarStyleNone){
        [infoDetailLabelBackgroundImage setHidden:YES];
        [infoDetailLabel setHidden:YES];
    }
    
    [infoTitleLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:16]];
    [infoDetailLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:16]];
    [infoDetailLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
}

@end
