//
//  StatsViewController.h
//  DailyCommute
//
//  Created by Weston Catron on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GraphView.h"
#import "Commute.h"
#import "Route.h"
#import "RecieptViewController.h"
#import "TotalsGraph.h"

@class StatsViewController;

@protocol StatsViewControllerDelegate <NSObject>

-(void)showCancelButton;
- (void)hideCancelButton;
-(BOOL)isInRoute;
- (IBAction)toggleStatMapAndGraph:(id)sender;
-(Commute *)getCurrentCommute;
- (void)showExAndCheckButtons;

@end

@protocol StatsViewControllerDataSource <NSObject>



@end

@interface StatsViewController : UIViewController <GraphViewControllerDataSource,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,ADBannerViewDelegate> {
    IBOutlet UIImageView *backgroundImageView;
    RecieptViewController *recieptViewController;
    BOOL ShowingView;
    IBOutlet GraphView *graphView;
    int dayOffset;
    IBOutlet UILabel *previousLabel;
    IBOutlet UILabel *averageLabel;
    IBOutlet UILabel *fastestLabel;
    IBOutlet UILabel *slowestLabel;
    
    IBOutlet UILabel *previousTitle;
    IBOutlet UILabel *averageTitle;
    IBOutlet UILabel *fastestTitle;
    IBOutlet UILabel *slowestTitle;

    
    IBOutlet UIImageView *topStatsImageView;
    
    IBOutlet UIButton *fromDateButton;
    IBOutlet UIButton *toDateButton;
    IBOutlet UIDatePicker *currentDatePicker;
    NSDate *toDate;
    NSDate *fromDate;
    
    IBOutlet UITableView *statsTableView;
    
    BOOL showingGraph;
    BOOL showingRoute;
    
    CGPoint startPoint;
    
    IBOutlet UIPageControl *pageControl;
    
    UIView *currentRouteView;
    
    BOOL showingToDatePrompt;
    BOOL showingFromDatePrompt;
    
    BOOL showingToTopStats;
    
    BOOL toRoutesNeedsUpdating;
    BOOL fromRoutesNeedsUpdating;

    //Week/Month/Year 
    
    IBOutlet UIButton *weekButton;
    IBOutlet UIButton *monthButton;
    IBOutlet UIButton *yearButton;
    
    IBOutlet ADBannerView *adBanner;
    
}

@property (nonatomic, assign) id<StatsViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *toRoutes;
@property (nonatomic, strong) NSArray *fromRoutes;
@property (nonatomic, strong) NSArray *toAndFromRoutes;
@property (nonatomic, strong) UIDatePicker *currentDatePicker;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) Commute *currentCommute;

@property (nonatomic, strong) TotalsGraph *totalsGraphVC;

- (NSArray *)getToAndFromRoutes;

- (IBAction)promptToDate:(id)sender;
- (IBAction)finalizeToDate:(id)sender;

- (IBAction)promptFromDate:(id)sender;
- (IBAction)finalizeFromDate:(id)sender;

- (void) reloadGraphView;
-(void)refreshTopStats ;
- (NSArray *)getToRoutes;
- (NSArray *)getFromRoutes;

- (NSDate *)getToDate;
- (NSDate *)getFromDate;

- (void)viewGraph;
- (void)viewList;

- (IBAction)switchCurrentView:(id)sender;

-(IBAction)toggleToFromTopStats:(id)sender;

- (void)setFonts;
-(void)hideDateLengthButtons;
-(void)showDateLengthButtons;
- (void)closeRecieptViewWithNoChanges;
-(void)disappearStatsView;
-(void)showStatsView;
-(void)hideStatsView;

@end
