//
//  GraphListViewController.m
//  Daily-Commute
//
//  Created by James Allen on 9/1/12.
//  Copyright (c) 2012 James Allen. All rights reserved.
//

#import "GraphListViewController.h"
#import "CommuteTimeScatterPlotViewController.h"
#import "BarGraphViewController.h"

@interface GraphListViewController ()

@end

@implementation GraphListViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Graphs";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.fetchedResultsController = [self fetchedResultsController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GraphCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Commute History Graph";
            break;
        case 1:
            cell.textLabel.text = @"Time Bar Graph";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self viewCommuteGraph];
            break;
        case 1:
            [self viewBarGraph];
            break;
        default:
            break;
    }
}

-(void) viewCommuteGraph {
    CommuteTimeScatterPlotViewController *ctGraph = [[CommuteTimeScatterPlotViewController alloc] init];
    [self presentViewController:ctGraph animated:YES completion:nil];
}

-(void) viewBarGraph {
    BarGraphViewController *bgGraph = [[BarGraphViewController alloc] init];
    [self presentViewController:bgGraph animated:YES completion:nil];
}
@end
