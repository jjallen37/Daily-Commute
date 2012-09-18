//
//  InRouteViewController.h
//  DailyCommute
//
//  Created by Weston Catron on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "Route.h"
#import "MovingPoint.h"

@class CurrentRouteViewController;

@protocol CurrentRouteViewControllerDelegate <NSObject>

-(void)finishRecordingRoute;

@end

@interface CurrentRouteViewController : UIViewController<CLLocationManagerDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate> {
    IBOutlet UILabel *mainTimeLabel;
    IBOutlet UILabel *milisecondTimeLabel;
    IBOutlet UILabel *delayTimeLabel;
    IBOutlet UILabel *currentTimeLabel;
    
    //Labels for debugging the delay/tracking
    IBOutlet UILabel *tempDistLabel;
    IBOutlet UILabel *tempMPHLabel;
    IBOutlet UILabel *tempTimeLabel;
    
    NSTimeInterval delayTime;
    NSUInteger consecutiveDelays;
    NSTimer *routeTimer;
    NSTimer *locationTimer;
    
    CLLocationManager *locManager;
    CLLocationSpeed currentSpeed;
}

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) Route *route;
@property (nonatomic, assign) id<CurrentRouteViewControllerDelegate> delegate;

-(void)startRoute:(Route *)newRoute;
-(void)updateTime:(id)sender;//updates time labels
-(void)updateLocation:(id)sender;//update location
-(void)cancelRoute;
-(void)finishRoute:(id)sender;
-(void)animateDelayIncrease;
-(NSTimeInterval)getAverageTime;

@end
