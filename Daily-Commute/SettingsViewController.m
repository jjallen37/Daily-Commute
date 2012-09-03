//
//  SettingsTableViewController.m
//  DailyCommute
//
//  Created by James Allen on 3/26/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "NewCommuteViewController.h"
#import "CommuteSettingsViewController.h"
#import "TipsViewController.h"
#import "Commute.h"
#import "SettingsCell.h"

@implementation SettingsViewController

@synthesize managedObjectContext;
@synthesize commuteArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setTitle:@"Settings"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set some table view properties or something
    [self.tableView setAlwaysBounceVertical:YES];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //Font
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:22];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.shadowOffset = CGSizeMake(2,2);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor =[UIColor whiteColor];
	titleLabel.text = self.title;
	self.navigationItem.titleView = titleLabel;
    
    
    
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
    if([objects count]==0){
        commuteArray = [[NSMutableArray alloc] init];
        [self.navigationItem setHidesBackButton:YES animated:NO];
    }else{
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
                              message: @"Sorry in the free version we only allow one commute. \n Upgrade now to have multiple commutes!"
                              delegate: self
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    aNewCommute = [NSEntityDescription insertNewObjectForEntityForName:@"Commute" inManagedObjectContext:managedObjectContext];
    
    NewCommuteViewController *newCommuteScreen = [[NewCommuteViewController alloc] init];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        // Return the number of rows in the section.
        NSUInteger count = [commuteArray count];
        if (self.editing) {
            count++;
        }
        return count;
    }else  if (section == 1) {
        return 2;
    }
    else {
        return 1;
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
    NSUInteger row = indexPath.row;
	
	if ((indexPath.section == 0 && row == [commuteArray count]) || indexPath.section == 1) {
        
		// This is the insertion cell.
		static NSString *InsertionCellIdentifier = @"InsertionCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InsertionCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InsertionCellIdentifier];
			cell.textLabel.text = @"Add Destination";
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:19]];
        if(indexPath.section == 1){
            if (indexPath.row == 0)
                cell.textLabel.text = @"Tutorial";
            else
                cell.textLabel.text = @"Tips";
        }
		return cell;
	}
    
    static NSString *CellIdentifier = @"SettingsCell";
    SettingsCell *cell = (SettingsCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SettingsCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell =  (SettingsCell *) currentObject;
                break;
            }
        }
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Signika-Bold" size:19]];
    
    if (indexPath.section == 0) {
        Commute *tempCommute = [commuteArray objectAtIndex:indexPath.row];
        cell.textLabel.text = tempCommute.name;
        
        if([[userDefaults objectForKey:kCurrentCommuteKey] isEqualToString:tempCommute.name]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.navigationItem.backBarButtonItem.title = tempCommute.name;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
    else if (indexPath.section == 2) {
        cell.textLabel.text = @"Restore Pro Version";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0://Commutes
            if (isEditing) {
                if (indexPath.row==commuteArray.count) {
                    [self presentNewCommuteView:nil];
                }else{
                    //Edit shit
                }
            }
            break;
        case 1://Tutorial tips
            switch (indexPath.row) {
                case 0://Tutorial
                    break;
                case 1://Tips
                    break;
                    
                default:
                    break;
            }
            break;
        case 2://Restore pro
            break;
            
            
        default:
            break;
    }
    
//    
//    if(indexPath.section==1 && indexPath.row == 0){
//        [(AppDelegate *)[[UIApplication sharedApplication] delegate] showTutorial];
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
//        CommuteSettingsViewController *commuteSettingsTVC = [[CommuteSettingsViewController alloc] initWithCommute:[commuteArray objectAtIndex:indexPath.row]];
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



#pragma mark - Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// The add row gets an insertion marker, the others a delete marker.
    if (indexPath.section != 0) {
        return UITableViewCellEditingStyleNone;
    }
    
	if (indexPath.row == [commuteArray count]) {
		return UITableViewCellEditingStyleInsert;
	}
    
    
    return UITableViewCellEditingStyleDelete;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
	
	// Don't show the Back button while editing.
	[self.navigationItem setHidesBackButton:editing animated:YES];
	
	[self.tableView beginUpdates];
	
    
    NSUInteger count = [commuteArray count];
    NSArray *commuteInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:0]];
    
	// Add or remove the Add row as appropriate.
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
	if (editing) {
		if (animated) {
			animationStyle = UITableViewRowAnimationFade;
		}
		[self.tableView insertRowsAtIndexPaths:commuteInsertIndexPath withRowAnimation:animationStyle];
        
	}
	else {
        [self.tableView deleteRowsAtIndexPaths:commuteInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
	
    
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
	
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create new commute.
        [self presentNewCommuteView:nil];
	}
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