//
//  GraphViewController.h
//  Daily-Commute
//
//  Created by James Allen on 9/1/12.
//  Copyright (c) 2012 James Allen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController <NSFetchedResultsControllerDelegate, CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *routeArray;
@property (strong, nonatomic) NSMutableArray *timeIntervalArray;
@property (strong, nonatomic) NSMutableArray *dateStringArray;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
@end
