//
//  TipsViewController.m
//  DailyCommute
//
//  Created by Bobby Wilson on 6/8/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "TipsViewController.h"

@interface TipsViewController ()

@end

@implementation TipsViewController

//@synthesize navController;


-(void)viewWillAppear:(BOOL)animated{
    [self fetchTweets];
    [self setTitle:@"Tips"];
    
    /*
    //Title Font
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:22];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.shadowOffset = CGSizeMake(0,2);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor =[UIColor whiteColor];
	titleLabel.text = self.title;	
	self.navigationItem.titleView = titleLabel;	
     */
 
// Note: We will not use dates in the tips feed
    dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    
    tweetFormatter = [[NSDateFormatter alloc] init];
    
    [tweetFormatter setDateFormat:@"MMM dd, h:mm a"];
    
    
}


- (void)fetchTweets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: @"http://api.twitter.com/1/statuses/user_timeline/DailyCommuteApp.json"]];
        
        NSError* error;
        
        tweets = [NSJSONSerialization JSONObjectWithData:data
                                                 options:kNilOptions
                                                   error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->tipsTableView reloadData];
        });
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
//Table View Settings
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    tableView.backgroundColor = [UIColor clearColor];
    // Nonstandard colors
    //[UIColor colorWithRed:0xA3/255.0 green:0xA3/254.0 blue:0xA3/253.0 alpha:1];
    // Standard Colors 
    //[UIColor yellowColor];
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
    NSString *text = [tweet objectForKey:@"text"];
    NSDate *tweetDate = [dateFormatter dateFromString:[tweet objectForKey:@"created_at"]];
    //NSLog(@"Time Interval Since Now: %f",[tweetDate timeIntervalSinceNow]);
    //NSString *name = [[tweet objectForKey:@"user"] objectForKey:@"name"];
    
    //Tweet
    UITextView *tweetLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, 300, 70)];
    //(90, -5, 225, 80)];
    //    UILabel *tweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 260, 80)];
    //    [tweetLabel setNumberOfLines:4];
    tweetLabel.backgroundColor = [UIColor clearColor];
    [tweetLabel setText:text];
    [tweetLabel setFont:[UIFont fontWithName:@"DroidSansMono" size:14]];
    [tweetLabel setEditable:NO];
    [tweetLabel setScrollEnabled:NO];
    tweetLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    [cell addSubview:tweetLabel];    
    
    //Date
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 50, 225, 25)];
    dateLabel.backgroundColor = [UIColor clearColor];
    [dateLabel setNumberOfLines:1];
    [dateLabel setTextAlignment:UITextAlignmentRight];
    [dateLabel setText:[tweetFormatter stringFromDate:tweetDate]];
    [dateLabel setTextColor:[UIColor grayColor]];
    //[UIColor colorWithRed:0xB3/255.0 green:0xB3/255.0 blue:0xB3/255.0 alpha:1]];
    //
    [dateLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [cell addSubview:dateLabel];  
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    //Icon
    // UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 75, 75)];
    // [iconImage setImage:[UIImage imageNamed:@"Shortcuts-Icon.png"]];
    
    // [cell addSubview:iconImage];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*RetweetViewController *retweets = [[RetweetViewController alloc] initWithNibName:@"RetweetViewController" bundle:nil];
     
     NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
     
     NSLog(@"originaltweet: %@",[tweet objectForKey:@"id_str"]);
     
     [retweets setOriginalTweetID:[tweet objectForKey:@"id_str"]];
     
     [self.navigationController pushViewController:retweets animated:YES];
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sendEasyTweet:(id)sender {
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:@"@DailyCommuteApp "];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        NSString *output;
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                // The cancel button was tapped.
                output = @"Tweet cancelled.";
                break;
            case TWTweetComposeViewControllerResultDone:
                // The tweet was sent.
                output = @"Tweet done.";
                break;
            default:
                break;
        }
        
        //[self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
        
        // Dismiss the tweet composition view controller.
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [self presentModalViewController:tweetViewController animated:YES];
}


@end
