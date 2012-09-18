//
//  NewInfoCell.h
//  DailyCommute
//
//  Created by Harlan Haskins on 9/13/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewInfoCell : UITableViewCell
typedef enum {
    NewInfoCellDetailBarStyleDepartIn, // Blue Bar
    NewInfoCellDetailBarStyleNormal,
} NewInfoCellDetailBarStyle;


@property (strong, nonatomic) IBOutlet UILabel *infoTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *infoDetailLabelBackgroundImage;
@property (strong, nonatomic) IBOutlet UILabel *infoDetailLabel;
@property (nonatomic, strong) IBOutlet UIImageView *clockImageView;
@property (nonatomic, strong) IBOutlet UIImageView *departInImageView;

-(void)setInfoCellDetailBarStyle:(InfoCellDetailBarStyle)style;


@end
