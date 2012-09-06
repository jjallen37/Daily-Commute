//
//  GraphView.h
//  DailyCommute
//
//  Created by Weston Catron on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ECCommon.h"
#import "ECGraph.h"

@class GraphView;

@protocol GraphViewDataSource <NSObject>

-(NSInteger)numberOfLinesOnGraph:(GraphView *)graphView;
-(NSInteger)numberOfPointsOnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber;
-(NSInteger)valueForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber;
-(NSDate *)dateForPoint:(NSInteger)point OnGraph:(GraphView *)graphView forLine:(NSInteger)lineNumber;
-(NSInteger)greatestValueOnGraph:(GraphView *)graphView;

-(UIColor *)colorForLine:(NSInteger)lineNumber OnGraph:(GraphView *)graphView;

@end

@interface GraphView : UIView <ECGraphDelegate> {
    CGContextRef		_context;
}

@property(nonatomic,retain) IBOutlet id <GraphViewDataSource> dataSource;

-(void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint lineWidth:(int)lineWidth color:(UIColor *)color;
-(void)drawCircleAtPoint:(CGPoint)center withDiameter:(float)diameter fillColor:(UIColor *)fillColor stockeColor:(UIColor *)stockeColor;
-(void)drawWords:(NSString *)words AtPoint:(CGPoint)point color:(UIColor *)color;

@end
