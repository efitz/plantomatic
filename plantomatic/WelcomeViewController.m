//
//  WelcomeViewController.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "WelcomeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Utility.h"
#import "AppDelegate.h"

@interface WelcomeViewController ()
@property(nonatomic, readwrite) BOOL isPreviouslyAuthorized;
@property (strong, nonatomic) IBOutlet UIButton *getPlantsBtn;
@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Variable Initialization
    if([Utility isiOS7])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if([CLLocationManager locationServicesEnabled]==NO ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        self.isPreviouslyAuthorized=NO;
    }
    else
    {
        self.isPreviouslyAuthorized=YES;
    }

    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=1;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.33];
    [self.getPlantsBtn.layer addAnimation:theAnimation forKey:@"animateOpacity"]; //myButton.layer instead of
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoPlantsScreen) name:@"GoAHeadToUseLocationsNotification" object:nil];
    
    CALayer *doneBtnLayer = [self.getPlantsBtn layer];
    [doneBtnLayer setMasksToBounds:YES];
    [doneBtnLayer setCornerRadius:5.0f];
    doneBtnLayer.borderWidth=1;
    doneBtnLayer.borderColor=[[UIColor blackColor] CGColor];
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) gotoPlantsScreen
{
    if (!self.isPreviouslyAuthorized) {
        [self performSegueWithIdentifier:@"showDetail" sender:self];
        
//        [[NSUserDefaults standardUserDefaults]
//         setObject:[NSNumber numberWithBool:NO] forKey:@"isNeedToShowWelcome"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}





- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    BOOL returnValue=YES;
    
    
    NSLog(@"%@",[CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse?@"Authorized":@"Not Authorized");
    NSLog(@"%@",[CLLocationManager locationServicesEnabled]==YES?@"Location service Enabled":@"Location service Disabled");
    
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([identifier isEqualToString:@"showDetail"]) {
        NSLog(@"Segue Blocked");
        //Put your validation code here and return YES or NO as needed
        
        
        if([CLLocationManager locationServicesEnabled]==NO ||
           [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            [appDelegate getLocationUpdates];
            returnValue=NO;
            
//            [[NSUserDefaults standardUserDefaults]
//             setObject:[NSNumber numberWithBool:YES] forKey:@"isNeedToShowWelcome"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if([CLLocationManager locationServicesEnabled]==NO ||
           [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            //Location services must be enabled to view local plants
            //plantomatic will not work with out Location Services. To use this app, please go to Settings and enabled Location Services
            
            //Location services must be enabled\nto view local events
            
            [Utility showAlert:@"" message:@"Plantomatic will not work with out Location Services. To use this app, please go to Settings and enabled Location Services"];
            returnValue=NO;
            
//            [[NSUserDefaults standardUserDefaults]
//             setObject:[NSNumber numberWithBool:YES] forKey:@"isNeedToShowWelcome"];
//            [[NSUserDefaults standardUserDefaults] synchronize];

        }
        else if([CLLocationManager locationServicesEnabled]==YES && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            //The condition for ios8 to work with location manager            
            //kCLAuthorizationStatusAuthorizedWhenInUse
            [appDelegate getLocationUpdates];
        }
        
        else
        {
//            [[NSUserDefaults standardUserDefaults]
//             setObject:[NSNumber numberWithBool:NO] forKey:@"isNeedToShowWelcome"];
//            [[NSUserDefaults standardUserDefaults] synchronize];

        }
    }
    
    return returnValue;
}


@end
