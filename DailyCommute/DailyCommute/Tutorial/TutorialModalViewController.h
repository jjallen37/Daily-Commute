//
//  TutorialModalViewController.h
//  DailyCommute
//
//  Created by James Allen on 4/17/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialModalViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) IBOutlet UIScrollView *scrllView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

-(IBAction)dismissTutorial;

@end
