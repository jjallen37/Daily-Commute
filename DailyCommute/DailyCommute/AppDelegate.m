//
//  AppDelegate.m
//  DailyCommute
//
//  Created by James Allen on 3/6/12.
//  Copyright (c) 2012 Valley Rocket. All rights reserved.
//

#import "AppDelegate.h"
#import "TutorialModalViewController.h"
#import "RootViewController.h"
#import "GraphListViewController.h"
#import "CommuteListViewController.h"
#import "SettingsTableViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar@1x.png"] forBarMetrics:UIBarMetricsDefault];

    //Tab 1 - Root Commute VC
    RootViewController *rootCommuteVC = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    rootCommuteVC.title = @"Commute";
    UINavigationController *tab1 = [[UINavigationController alloc] initWithRootViewController:rootCommuteVC];
    
    //Tab 2 - GraphListVC
    GraphListViewController *listVC = [[GraphListViewController alloc] initWithStyle:UITableViewStylePlain];
    listVC.title = @"Graphs";
    UINavigationController *tab2 = [[UINavigationController alloc] initWithRootViewController:listVC];
    
    //Tab 3 - CommuteListVC
    CommuteListViewController *commuteListVC = [[CommuteListViewController alloc] initWithStyle:UITableViewStylePlain];
    commuteListVC.title = @"History";
    UINavigationController *tab3 = [[UINavigationController alloc] initWithRootViewController:commuteListVC];
                                    
    //Tab 4 - Settings VC
    SettingsTableViewController *settingsVC = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsVC.title = @"Settings";
    UINavigationController *tab4 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    //Initilize the Tab Bar
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[tab1, tab2, tab3, tab4];
    
    //Connect the core data
    rootCommuteVC.managedObjectContext = self.managedObjectContext;
    listVC.managedObjectContext = self.managedObjectContext;
    commuteListVC.managedObjectContext = self.managedObjectContext;
    self.window.rootViewController = tabBarController;
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;

    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    rootVC = [[RootViewController alloc] init];
//    [rootVC setManagedObjectContext:__managedObjectContext];
//    
//    //Set up Root VC
//    //UINib *nib = [UINib nibWithNibName:@"NavController" bundle:nil];
//    //navController = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];    
//    
//    UIViewController *viewController = [[UIViewController alloc] init];
//    
//    [viewController.view setFrame:CGRectMake(0, 0, 0, 0)];
//    
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar@1x.png"] forBarMetrics:UIBarMetricsDefault];
//
//    navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
//    [navController.view setFrame:CGRectMake(0, 0, 0, 480)];
//    
//    statsVC = [[StatsViewController alloc] initWithNibName:@"StatsViewController" bundle:nil];
//    [statsVC.view setFrame:CGRectMake(0, 480, 320, 480)];
//    [statsVC setDelegate:rootVC];
//    [rootVC setStatsViewController:statsVC];
//    
//    [viewController.view addSubview:navController.view];
//    [viewController.view addSubview:statsVC.view];
//    
//    self.window.rootViewController = viewController;
//    
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if(![(NSString *)[defaults objectForKey:@"hasSeenTutorial"] isEqualToString:@"YES"]){
//        [self showTutorial];
//    }    
//    return YES;
}
//
//- (void)showTutorial{
//    TutorialModalViewController *tutorialVC = [[TutorialModalViewController alloc] init];
//    tutorialVC.navController = self.navController;
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//    [navController presentModalViewController:tutorialVC animated:YES];
//    [self.statsVC.view setHidden:YES];
//}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DailyCommute" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DailyCommute.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
