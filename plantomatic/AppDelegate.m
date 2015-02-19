//
//  AppDelegate.m
//  plantomatic
//
//  Created by ehfitz on 2/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "GPSManager.h"
#import "PlantsViewController.h"
#import "InternetDetector.h"


@interface AppDelegate()
@property (nonatomic, strong) UIImageView* splashView;

-(void) getLocationUpdates;

@end

@implementation AppDelegate
@synthesize databaseName,databasePath;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    self.databaseName = @"PlantoMaticDB.sqlite";
//    
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDir = [documentPaths objectAtIndex:0];
//    self.databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
//    
//    [self createAndCheckDatabase];
    
    //Init Internet Detector
    [InternetDetector sharedManager];
    
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor lightGrayColor];
    shadow.shadowOffset = CGSizeMake(0, -1);
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: [UIColor blackColor],
                                                           UITextAttributeTextShadowColor: [UIColor lightGrayColor],
                                                           NSShadowAttributeName: shadow,
                                                           NSFontAttributeName: [UIFont fontWithName:@"ChunkFive" size:18.0],
                                                           }];
    
    
    NSNumber *isCommonNameAvaialble = [[NSUserDefaults standardUserDefaults]
                                          valueForKey:@"isCommonNameAvailable"];
    
    if (isCommonNameAvaialble==nil)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCommonNameAvailable"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSNumber *isImageAvailable = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:@"isImageAvailable"];
    
    if (isImageAvailable==nil)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isImageAvailable"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *isSortOrderAscending = [[NSUserDefaults standardUserDefaults]
                                  valueForKey:@"sortOrder"];
    
    if (isSortOrderAscending==nil)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"sortOrder"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    


    NSMutableDictionary *flowerColorsDictionary = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:@"flowerColorsDictionary"];
    
    if (flowerColorsDictionary==nil)
    {
        flowerColorsDictionary=[@{@"Red":@{@"isSelected":@YES},
                                 @"Pink":@{@"isSelected":@YES},
                                 @"Violet":@{@"isSelected":@YES},
                                 @"Purple": @{@"isSelected":@YES},
                                 @"Blue":@{@"isSelected":@YES},
                                 @"Green": @{ @"isSelected":@YES},
                                 @"Yellow":@{@"isSelected":@YES},
                                 @"Orange":@{@"isSelected":@YES},
                                 @"Brown":@{@"isSelected":@YES},
                                 @"Gray":@{@"isSelected":@YES},
                                 @"Black":@{@"isSelected":@YES},
                                 @"White":@{@"isSelected":@YES},
                                 @"Unknown-Flower":@{@"isSelected":@YES}
                                 } mutableCopy];
        
        [[NSUserDefaults standardUserDefaults] setObject:flowerColorsDictionary forKey:@"flowerColorsDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSMutableDictionary *growthFormDictionary = [[NSUserDefaults standardUserDefaults]
                                          valueForKey:@"growthFormDictionary"];
    
    if (growthFormDictionary==nil)
    {
        growthFormDictionary=[@{@"Aquatic":@{@"isSelected":@YES},
                               @"Bryophyte":@{@"isSelected":@YES},
                               @"Epiphyte":@{@"isSelected":@YES},
                               @"Fern": @{@"isSelected":@YES},
                               @"Grass":@{@"isSelected":@YES},
                               @"Herb": @{ @"isSelected":@YES},
                               @"Parasite":@{@"isSelected":@YES},
                               @"Shrub":@{@"isSelected":@YES},
                               @"Tree":@{@"isSelected":@YES},
                               @"Vine":@{@"isSelected":@YES},
                               @"Unknown":@{@"isSelected":@YES}} mutableCopy];
        
        [[NSUserDefaults standardUserDefaults] setObject:growthFormDictionary forKey:@"growthFormDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    NSMutableArray* familiesSelected=[[NSUserDefaults standardUserDefaults] objectForKey:@"familiesSelected"];

    if (familiesSelected==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"familiesSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSMutableArray* sortColumns=[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"];
    
    if (sortColumns==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"sortColumns"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    
    NSNumber *isNeedToShowWelcome = [[NSUserDefaults standardUserDefaults]
                                     valueForKey:@"isNeedToShowWelcome"];
    
    
    BOOL isNeedToStartWithWelcomeScreen=YES;
    
    if (isNeedToShowWelcome==nil) {
        isNeedToStartWithWelcomeScreen=YES;
        
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithBool:YES] forKey:@"isNeedToShowWelcome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if (isNeedToShowWelcome.boolValue) {
            
            //show storyboard that have welcome screen
            isNeedToStartWithWelcomeScreen=YES;
        }
        else
        {
            //show storyboard that dont have welcome screen
            isNeedToStartWithWelcomeScreen=NO;
        }
        
    }
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *navController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"MyNavigationController"];
    
    if (isNeedToStartWithWelcomeScreen==NO) {
        
         PlantsViewController *plantsViewController = (PlantsViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"PlantsStoryBoardID"];
        
        navController=[navController initWithRootViewController:plantsViewController];
    }
    
    
    self.window.rootViewController = navController;
    
    [self.window makeKeyAndVisible];
    
    

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self getLocationUpdates];
    }
    

    
    UIImageView* splashView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
	{
		if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
		{
			splashView.image = [UIImage imageNamed:@"americas-568h@2x.png"];
			
		}
		else
		{
			//iphone 3.5 inch screen
			splashView.image = [UIImage imageNamed:@"americas@2x.png"];
		}
	}
    
    self.splashView=splashView;
    [self.window addSubview:self.splashView];
    [self.window bringSubviewToFront:self.splashView];

    // Do your time consuming setup
    [self performSelector:@selector(removeSplashScreen) withObject:nil afterDelay:2.0];
    
    
    
    return YES;
}

-(void) removeSplashScreen
{
    [self.splashView removeFromSuperview];
    self.splashView=nil;
}

-(void) createAndCheckDatabase
{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    
    if(success) return;
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
    
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark GetLocalEvents Methods

-(void) getLocationUpdates
{
    [[GPSManager getInstance] registerForCurrentLocationUpdatesWithDelegate:self completionCallSelector:@selector(currentLocationUpdate:) failureCallselector:@selector(unableToGetCurrentLocation:)];
}


-(void) currentLocationUpdate:(CLLocation*)currentLocation
{
    //[[GPSManager getInstance] unregisterForCurrentLocationUpdates];
    self.currentLocation=currentLocation;
}

-(void) unableToGetCurrentLocation:(NSString*)errorMessage
{
    //[[GPSManager getInstance] unregisterForCurrentLocationUpdates];
    //[self.delegate myEventServiceLocalEventsFailedWithReason:errorMessage];
}




@end
