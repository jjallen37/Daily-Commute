//
//  TutorialModalViewController.m
//  DailyCommute
//
//  Created by James Allen on 4/17/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "AppDelegate.h"
#import "TutorialModalViewController.h"

#define kNumberOfPictures 9

@implementation TutorialModalViewController

@synthesize navController;
@synthesize scrllView;
@synthesize pageControl;
@synthesize doneButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.wantsFullScreenLayout = YES;
    
    [scrllView setContentSize:CGSizeMake(320*kNumberOfPictures, 460)];
    [scrllView setContentOffset:CGPointMake(0, 0) animated:NO];
    for (NSUInteger i = 0; i < kNumberOfPictures; i++) {
        UIImageView *imVw = [[UIImageView alloc] initWithImage:
         [UIImage imageNamed:
          [NSString stringWithFormat:@"%i.png",i]]];
        [imVw setFrame:CGRectMake(320*i, 0, 320, 480)];
        [scrllView addSubview:imVw];
    }
    
    [doneButton setFrame:CGRectMake(265, 365, 48, 38)];
    [scrllView addSubview:doneButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [doneButton setFrame:CGRectMake(265+scrollView.contentOffset.x, 365, 48, 38)];

}

-(void)dismissTutorial{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"YES" forKey:@"hasSeenTutorial"];
    [userDefaults synchronize];
    
    self.wantsFullScreenLayout = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    [self.navController dismissModalViewControllerAnimated:YES];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate.statsVC.view setHidden:NO];

}

@end
