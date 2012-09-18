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
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSString *currentCommuteName;
-(NSString*) timeFormatted:(int)totalSeconds;
-(NSNumber*) timeIntervalOfRoute:(Route*)route;
-(NSString*) stringForRoute:(Route*)route;
-(NSNumber*) delayOfRoute:(Route*)route;
-(NSNumber*) longestCommute;
-(NSNumber*) shortestCommute;
-(NSNumber*) longestDelay;
@end
