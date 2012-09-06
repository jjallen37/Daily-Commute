//
//  GraphViewController.h
//  DailyCommute
//
//  Created by Weston Catron on 4/17/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "Route.h"

@class GraphViewController;

@protocol GraphViewControllerDataSource <NSObject>

-(NSArray *)getToRoutes;
-(NSArray *)getFromRoutes;

@end

@interface GraphViewController : UIViewController <GraphViewDataSource> {
    GraphView *view;
    id <GraphViewControllerDataSource> dataSource;
}

@property (nonatomic, strong) GraphView *view;
@property (nonatomic, strong) id <GraphViewControllerDataSource> dataSource;

@end
