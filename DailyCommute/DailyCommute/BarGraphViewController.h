//
//  SecondViewController.h
//  CorePlot
//
//  Created by Harlan Haskins on 8/14/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphViewController.h"

@interface BarGraphViewController : GraphViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>
@property (nonatomic, strong) CPTBarPlot *timePlot;
@end
