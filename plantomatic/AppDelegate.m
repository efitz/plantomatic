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
    
    
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
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
    splashView.image = [UIImage imageNamed:@"splash_screen2.png"];
    self.splashView=splashView;
    [self.window addSubview:self.splashView];
    [self.window bringSubviewToFront:self.splashView];

    // Do your time consuming setup
    [self performSelector:@selector(removeSplashScreen) withObject:nil afterDelay:1.0];
    
    
    
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
