//
//  InfoTableCell.h
//  DailyCommute
//
//  Created by James Allen on 3/20/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoTableCell : UITableViewCell

typedef enum {
    InfoCellDetailBarStyleBlue, // Blue Bar
    InfoCellDetailBarStyleTime,
    InfoCellDetailBarStyleOrange, // Orange Bara
    InfoCellDetailBarStyleNone
} InfoCellDetailBarStyle;


@property (strong, nonatomic) IBOutlet UILabel *infoTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *infoDetailLabelBackgroundImage;
@property (strong, nonatomic) IBOutlet UILabel *infoDetailLabel;
@property (nonatomic, strong) IBOutlet UIImageView *clockImageView;

-(void)setInfoCellDetailBarStyle:(InfoCellDetailBarStyle)style;

@end
