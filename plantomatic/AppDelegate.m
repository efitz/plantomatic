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
#import "Utility.h"
#import "Mixpanel.h"
#import "Constants.h"
<<<<<<< HEAD
#import "GAI.h"
=======
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


>>>>>>> 5a872873d163e43a24005533c358ca226fda7776

@interface AppDelegate()
@property (nonatomic, strong) UIImageView* splashView;

-(void) getLocationUpdates;

@end

@implementation AppDelegate
@synthesize databaseName,databasePath;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
    [Fabric with:@[CrashlyticsKit]];
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_TRACKER_ID];
    
    
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

//    NSShadow * shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor lightGrayColor];
//    shadow.shadowOffset = CGSizeMake(0, -1);
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: [UIColor blackColor],
//                                                           NSShadowAttributeName: shadow,
                                                           NSFontAttributeName: [UIFont fontWithName:@"ChunkFive" size:18.0],
                                                           }];
    
    [Utility initializeUserDefaults];
     
    
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
