//
//  CommuteSettingsTableViewControler.m
//  DailyCommute
//
//  Created by James Allen on 3/27/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "CommuteSettingsTableViewController.h"


@implementation CommuteSettingsTableViewController

@synthesize managedObjectContext;
@synthesize currentCommute;

-(id)initWithCommute:(Commute *)commute{
    //Initilize Objects
    currentCommute = commute;
    
    return [self init];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(hideKeyboard:)];
    
    //Date Formatter
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];//08:37 PM
    
    //Font
    [self setTitle:currentCommute.name];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Signika-Bold" size:22];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.shadowOffset = CGSizeMake(2,2);
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor =[UIColor whiteColor];
	titleLabel.text = self.title;	
	self.navigationItem.titleView = titleLabel;	
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    [self.tableView setEditing:YES];
}

-(void)hideKeyboard{
    [((EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField resignFirstResponder];
    [((EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textField resignFirstResponder];
    [((EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]).textField resignFirstResponder];
}

#pragma mark - Saving data
-(void)saveCommute{
    NSError *error;
    [managedObjectContext save:&error];
}

#pragma mark - editing rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [self.navigationItem setHidesBackButton:editing animated:animated];
    
    //Save edited data
    if(!editing){
        [self saveCommute];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /* NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     //If this commute is the main commute, only show the regular screen
     if([[userDefaults objectForKey:kCurrentCommuteKey] isEqualToString:currentCommute.name]){
     
     }else {
     return 2;
     }*/
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Editable Cells
    static NSString *CellIdentifier = @"EditableCell";
    
    EditableCell *cell = (EditableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditableCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell =  (EditableCell *) currentObject;
                break;
            }
        }
    }
    
    cell.textField.tag = indexPath.row;
    cell.textField.delegate = self;
    switch (indexPath.section) {
        case 0://Name
            cell.titleLabel.text = @"Name";
            cell.textField.tag = 0;
            if(currentCommute.name.length==0){
                cell.textField.placeholder = @"Commute Name";
            }else{
                cell.textField.text = currentCommute.name;
            }
            break;
        case 1://Arrival Time
            cell.titleLabel.text = @"Arrive By";
            [cell setInputViewStyle:InputViewStyleTimePicker];
            cell.textField.tag = 1;
            if (currentCommute.toArrivalTime != nil) {
                [cell.timePicker setDate:currentCommute.toArrivalTime];
            }
            if(currentCommute.toArrivalTime == nil){
                cell.textField.placeholder = @"Arrival Time";
            }else{
                cell.textField.text = [dateFormatter stringFromDate:currentCommute.toArrivalTime];
            }
            break;
        case 2://Departure time
            cell.titleLabel.text = @"Return By";
            [cell setInputViewStyle:InputViewStyleTimePicker];
            cell.textField.tag = 2;
            if (currentCommute.fromArrivalTime != nil) {
                [cell.timePicker setDate:currentCommute.fromArrivalTime];
            }
            if(currentCommute.fromArrivalTime == nil){
                cell.textField.placeholder = @"Time to be back";
            }else{
                cell.textField.text = [dateFormatter stringFromDate:currentCommute.fromArrivalTime];
            }
            break;
        default:
            break;
    }
    
    [cell setIndentationLevel:0];
    [cell setIndentationWidth:0];
    
    [cell setEditingAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [NSString stringWithFormat:@"Commute Title"];
            break;
        case 1:
            return [NSString stringWithFormat:@"Arrive By"];
            break;
        case 2:
            return [NSString stringWithFormat:@"Return By"];
            break;
            
        default:
            return @"";
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){//Make current commute button
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:currentCommute.name forKey:kCurrentCommuteKey];
        [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
        [defaults synchronize];
    }
    
    //Deselect the cell
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
}


#pragma mark - Textfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

//Saves text
- (void)textFieldDidEndEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 0://Name
            currentCommute.name = textField.text;
            break;
        case 1:
            currentCommute.toArrivalTime = ((UIDatePicker *)textField.inputView).date;
            break;
        case 2:
            currentCommute.fromArrivalTime = ((UIDatePicker *)textField.inputView).date;
            break;
        default:
            break;
    }
}

-(IBAction)hideKeyboard:(id)sender {
    
}


@end
