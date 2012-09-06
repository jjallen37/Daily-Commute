//
//  GraphView.m
//  DailyCommute
//
//  Created by Weston Catron on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"

#define startingX 40.0

@implementation GraphView

@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code here.
    
    _context = UIGraphicsGetCurrentContext();
    
	//ECGraph *graph = [[ECGraph alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height) withContext:_context isPortrait:NO];
    
    if ([dataSource numberOfLinesOnGraph:self] == 0) {
        
        [self drawWords:@"You must complete a roundtrip-commute" AtPoint:CGPointMake(39, 40) color:[UIColor blackColor]]; 
        [self drawWords:@"to view the graph." AtPoint:CGPointMake(97, 60) color:[UIColor blackColor]]; 
         
        return;
    }
    
    float xSpacing;
    float yMaxValue = [dataSource greatestValueOnGraph:self];
    float yRealMaxValue = 225;
    
    //NSLog(@"xSpacing:%f",xSpacing);
    
    //Y-Axis
    [self drawLineFromPoint:CGPointMake(startingX, self.frame.size.height-7) toPoint:CGPointMake(startingX, 0) lineWidth:1 color:[UIColor blackColor]]; 
    
    //X-Axis
    [self drawLineFromPoint:CGPointMake(startingX, self.frame.size.height-7) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height-7) lineWidth:1 color:[UIColor blackColor]]; 
    
    int incremtalValue = 60;
    if (yMaxValue > 1200) {
        incremtalValue = 120;
    }
    if (yMaxValue > 2400) {
        incremtalValue = 240;
    }
    if (yMaxValue > 3600) {
        incremtalValue = 360;
    }
    if (yMaxValue > 4800) {
        incremtalValue = 480;
    }
    if (yMaxValue > 6000) {
        incremtalValue = 600;
    } 
    if (yMaxValue > 7200) {
        incremtalValue = 720;
    } 
    if (yMaxValue > 8400) {
        incremtalValue = 840;
    }
    if (yMaxValue > 9600) {
        incremtalValue = 960;
    }
    if (yMaxValue > 10800) {
        incremtalValue = 1080;
    }
    if (yMaxValue > 12000) {
        incremtalValue = 1200;
    }
    
    for (int i = 0; i < yMaxValue+1 ; i = i + incremtalValue) {
        
        NSString *words;
        if ((i/60) < 10) {
             words = [NSString stringWithFormat:@"0%i:00",i/60];
        } else {
             words = [NSString stringWithFormat:@"%i:00",i/60];
        }
        
        float yValue = (yRealMaxValue-(i/yMaxValue)*yRealMaxValue)-14;
        
        if (yValue > 0) {
            [self drawWords:words AtPoint:CGPointMake(0, yValue) color:[UIColor blackColor]];
        } else {
            NSLog(@"----------%f-----------",yValue);
        }

    }
    
    /*NSArray *xAxisText = [NSArray arrayWithObjects:@"Su",@"M",@"Tu",@"W",@"Th",@"F",@"Sa", nil];
    
    for (int i = 1; i < 8; i++) {
        [self drawWords:[xAxisText objectAtIndex:i-1] AtPoint:CGPointMake(xSpacing*i-8, self.frame.size.height-15) color:[UIColor blackColor]];
    }*/
    
    for (int i = 0; i < [dataSource numberOfLinesOnGraph:self]; i++) {
        xSpacing = (self.frame.size.width-startingX)/([dataSource numberOfPointsOnGraph:self forLine:i]-1);
        
        for (int h = 0; h < [dataSource numberOfPointsOnGraph:self forLine:i]; h++) {
            float XValue;
            float YValue;
            if ([dataSource numberOfPointsOnGraph:self forLine:i] == 1) {
                XValue = startingX;
                YValue = (self.frame.size.height) - (([dataSource valueForPoint:h OnGraph:self forLine:i])/yMaxValue)*yRealMaxValue-7;
            } else {
                XValue = (xSpacing*h)+startingX;
                YValue = (self.frame.size.height) - (([dataSource valueForPoint:h OnGraph:self forLine:i])/yMaxValue)*yRealMaxValue-7;
            }
            
            [self drawCircleAtPoint:CGPointMake(XValue, YValue) withDiameter:6 fillColor:[UIColor clearColor] stockeColor:[dataSource colorForLine:i OnGraph:self]];
        }
        for (int h = 0; h < [dataSource numberOfPointsOnGraph:self forLine:i]-1; h++) {

            float XValue = (xSpacing*h)+startingX;
            float nextXValue = (xSpacing*(h+1))+startingX;
            
            NSLog(@"Value: %i / 60 * 279",[dataSource valueForPoint:h OnGraph:self forLine:i]);
                        
            float YValue = (self.frame.size.height) - (([dataSource valueForPoint:h OnGraph:self forLine:i])/yMaxValue)*yRealMaxValue-7;
            float nextYValue = (self.frame.size.height) - (([dataSource valueForPoint:h+1 OnGraph:self forLine:i]/yMaxValue)*yRealMaxValue)-7;
            
            NSLog(@"%i",[dataSource valueForPoint:h+1 OnGraph:self forLine:i]);
            
            
            NSLog(@"(%f,%f) (%f,%f)",XValue,YValue,nextXValue,nextYValue);
            
            [self drawLineFromPoint:CGPointMake(XValue, YValue) toPoint:CGPointMake(nextXValue, nextYValue) lineWidth:3 color:[dataSource colorForLine:i OnGraph:self]];
            
            
        }
    }
}

-(void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint lineWidth:(int)lineWidth color:(UIColor *)color
{
	CGContextBeginPath(_context);
	CGContextSetLineWidth(_context, lineWidth);
	CGContextMoveToPoint(_context, startPoint.x, startPoint.y);
	CGContextAddLineToPoint(_context, endPoint.x, endPoint.y);
	CGContextClosePath(_context);
	[color setStroke];
	CGContextStrokePath(_context);
}

-(void)drawCircleAtPoint:(CGPoint)center withDiameter:(float)diameter fillColor:(UIColor *)fillColor stockeColor:(UIColor *)stockeColor;
{	
	float radius = diameter * 0.5;
	CGRect oval = {center.x - radius,center.y - radius,diameter,diameter};
	//CGContextSetFillColor(context, CGColorGetComponents([fillColor CGColor]));
	//CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	[fillColor setFill];
	CGContextAddEllipseInRect(_context, oval);
	CGContextFillPath(_context);
	CGContextAddArc(_context,center.x,center.y,radius,0,2*M_PI,1);
	[stockeColor setStroke];
	CGContextStrokePath(_context);
}

-(void)drawWords:(NSString *)words AtPoint:(CGPoint)point color:(UIColor *)color 
{
	[color set];
	[words drawAtPoint:point withFont:[UIFont fontWithName:@"Signika-Bold" size:12]];
}

@end
