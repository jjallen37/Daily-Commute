//
//  SettingsTableViewController.m
//  DailyCommute
//
//  Created by James Allen on 3/26/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "SettingsTableViewController.h"

@implementation SettingsTableViewController

@synthesize managedObjectContext;
@synthesize commuteArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setAlwaysBounceVertical:YES];
    
    //Set the Title
    [self setTitle:@"Settings"];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentNewCommuteView:)];
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //Font
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:24];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.shadowOffset = CGSizeMake(0,2);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor =[UIColor whiteColor];
	titleLabel.text = self.title;
	self.navigationItem.titleView = titleLabel;
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.text = @"You're using Daily Commute version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.tableView.tableFooterView = versionLabel;
    
    
    //Global default object
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (managedObjectContext == nil)
    {
        managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    
    //Find the commute with the name of text label
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Commute"
                                              inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if(objects == nil){
        NSLog(@"Error in core data");
    }
    
    //If the commute doesnt exist, make it
    if([objects count] == 0) {
        commuteArray = [[NSMutableArray alloc] init];
        [self.navigationItem setHidesBackButton:YES animated:NO];
    }else {
        commuteArray = [objects mutableCopy];
    }
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    //    [self presentNewCommuteView:nil];
    
    
    //These 3 lines of code prevent a stupid bullshit error that made the table view snap to the top.
    UIViewController *derp = [[UIViewController alloc] init];
    [self.navigationController presentModalViewController:derp animated:NO];
    [self.navigationController dismissModalViewControllerAnimated:NO];
    
    
    [self.tableView reloadData];
}

#pragma mark - methods

-(IBAction)presentNewCommuteView:(id)sender{
    
    if (managedObjectContext == nil)
    {
        managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    
    //Find the commute with the name of text label
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Commute"
                                              inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"isProUpgradePurchased"] && [objects count] == 1){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Upgrade for more commutes!"
                              message: @"Sorry! In the free version we only allow one commute. \n Upgrade now to have multiple commutes!"
                              delegate: self
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    aNewCommute = [NSEntityDescription insertNewObjectForEntityForName:@"Commute" inManagedObjectContext:managedObjectContext];
    
    NewCommuteModalNavigationController *newCommuteScreen = [[NewCommuteModalNavigationController alloc] init];
    newCommuteScreen.delegate = self;
    newCommuteScreen.commute = aNewCommute;
    
    [self.navigationController presentModalViewController:newCommuteScreen animated:YES];
}

#pragma mark - New Commute Delegate
-(void)acceptCommute{
    [commuteArray addObject:aNewCommute];
    
    //Dismiss View
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
    
}

//Cancels new Commute
-(void)refuteCommute{
    //Delete Object
    [managedObjectContext deleteObject:aNewCommute];
    
    //Dismiss View
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view data source

-(NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 3) {
        NSString *title = [NSString stringWithFormat:@"You are using Daily Commute, version %@ from Valley Rocket, LLC.", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        return title;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [commuteArray count];
            break;
        case 1:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return [NSString stringWithFormat:@"Destinations"];
    }else if (section == 1) {
        return [NSString stringWithFormat:@"About"];
    }
    else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *InsertionCellIdentifier = @"InsertionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InsertionCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InsertionCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:19]];
    
    
    
    Commute *tempCommute;
    switch(indexPath.section){//Commutes
        case 0:
            tempCommute = [commuteArray objectAtIndex:indexPath.row];
            cell.textLabel.text = tempCommute.name;
            
            if([[userDefaults objectForKey:kCurrentCommuteKey] isEqualToString:tempCommute.name]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.navigationItem.backBarButtonItem.title = tempCommute.name;
            }else if(tableView.isEditing){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        case 1://Tips and tutorial
            if (indexPath.row == 0)
                cell.textLabel.text = @"Tutorial";
            else
                cell.textLabel.text = @"Tips";
            break;
        case 2://Restore pro version
            cell.textLabel.text = @"Restore Pro Version";
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case 3://Looking suave
            cell.textLabel.text = @"Questions? Comments? Email us!";
    }
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults;
    Commute *tempCommute;
    TipsViewController *tipsVC;
    UIAlertView *av;
    switch (indexPath.section) {
        case 0:
            if ([tableView isEditing]) {
                CommuteSettingsTableViewController *commuteSettingsTVC = [[CommuteSettingsTableViewController alloc] initWithCommute:[commuteArray objectAtIndex:indexPath.row]];
                commuteSettingsTVC.managedObjectContext = self.managedObjectContext;
                [self.navigationController pushViewController:commuteSettingsTVC animated:YES];
            }else{
                defaults = [NSUserDefaults standardUserDefaults];
                
                tempCommute = [commuteArray objectAtIndex:indexPath.row];
                
                [defaults setObject:tempCommute.name forKey:kCurrentCommuteKey];
                [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
                [defaults synchronize];
                
                [self.tableView reloadData];
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0://Tutorial
                    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] showTutorial];
                    
                    break;
                case 1://tutorial
                    tipsVC = [[TipsViewController alloc] init];
                    [self.navigationController pushViewController:tipsVC animated:YES];
                    return;
                default:
                    break;
            }
            break;
        case 2://Restore in app purchases
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            break;
        case 3:
            av = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Sending an email will close the app. We appreciate your feedback!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
            [av show];
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //    if(indexPath.section==1 && indexPath.row == 0){
    //        return;
    //    }else if(indexPath.section==1 && indexPath.row == 1){
    //        TipsViewController *tipsVC = [[TipsViewController alloc] init];
    //        [self.navigationController pushViewController:tipsVC animated:YES];
    //        return;
    //    }
    //    else if (indexPath.section == 2) {
    //        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    //    }
    //    if ([tableView isEditing] && indexPath.row != [commuteArray count]) {
    //        CommuteSettingsTableViewController *commuteSettingsTVC = [[CommuteSettingsTableViewController alloc] initWithCommute:[commuteArray objectAtIndex:indexPath.row]];
    //        commuteSettingsTVC.managedObjectContext = self.managedObjectContext;
    //        [self.navigationController pushViewController:commuteSettingsTVC animated:YES];
    //    } else if ([tableView isEditing] && indexPath.row == [commuteArray count]) {
    //        [self presentNewCommuteView:nil];
    //    }else if (indexPath.section != 2) {
    //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //
    //        Commute *tempCommute = [commuteArray objectAtIndex:indexPath.row];
    //
    //        [defaults setObject:tempCommute.name forKey:kCurrentCommuteKey];
    //        [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    //        [defaults synchronize];
    //
    //        [self.tableView reloadData];
    //    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Warning"]) {
        NSURL *emailUrl;
        switch(buttonIndex) {
            case 1:
                emailUrl = [NSURL URLWithString:@"mailto:support@valeyrocket.com"];
                [[UIApplication sharedApplication] openURL:emailUrl];
        }
    }
}

#pragma mark - Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Only commutes are in edit mode.
    if (indexPath.section != 0) {
        return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
	
	// Don't show the Back button while editing.
	[self.navigationItem setHidesBackButton:editing animated:YES];
    
    
    //
    //
    //
    //    NSUInteger count = [commuteArray count];
    //    NSArray *commuteInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:0]];
    //
    //	// Add or remove the Add row as appropriate.
    //    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
    //	if (editing) {
    //		if (animated) {
    //			animationStyle = UITableViewRowAnimationFade;
    //		}
    //		[self.tableView insertRowsAtIndexPaths:commuteInsertIndexPath withRowAnimation:animationStyle];
    //
    //	}
    //	else {
    //        [self.tableView deleteRowsAtIndexPaths:commuteInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    //    }
    //
    //
    
	// If editing is finished, save the managed object context.
	if (!editing) {
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
        if(commuteArray.count == 0){
            [self.navigationItem setHidesBackButton:YES animated:NO];
        }else {
            [self.navigationItem setHidesBackButton:NO animated:YES];
        }
        
        if (self.currentCommute == nil && commuteArray.count!=0) {
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
	}
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
		// Find the commute to delete.
		Commute *commute = [commuteArray objectAtIndex:indexPath.row];
        
		[managedObjectContext deleteObject:commute];
        
		// Remove the tag from the tags array and the corresponding row from the table view.
		[commuteArray removeObject:commute];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		// Save the change.
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
    }
    //
    //	if (editingStyle == UITableViewCellEditingStyleInsert) {
    //		// Create new commute.
    //        [self presentNewCommuteView:nil];
    //	}
}

-(Commute *)currentCommute{
    NSString *commuteName = [userDefaults stringForKey:kCurrentCommuteKey];
    //Load the context if needed
    if (managedObjectContext == nil)
    {
        managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    
    //Find the commute with the name of text label
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",commuteName];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Commute"
                                              inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if(objects == nil){
        NSLog(@"Error in core data");
    }
    //If the commute doesnt exist, make it
    if([objects count]==0){
        return nil;
    }else{
        return [objects objectAtIndex:0];
    }
    
}

@end
