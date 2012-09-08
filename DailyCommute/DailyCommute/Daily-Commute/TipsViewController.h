//
//  TipsViewController.h
//  DailyCommute
//
//  Created by Bobby Wilson on 6/8/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>


@interface TipsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *tweets;
    IBOutlet UITableView *tipsTableView;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *tweetFormatter;
    
}

//@property (nonatomic, strong) UINavigationController *navController;


- (IBAction)sendEasyTweet:(id)sender;



@end
