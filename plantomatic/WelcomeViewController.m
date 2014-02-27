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


@interface WelcomeViewController ()

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



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    BOOL returnValue=YES;
    
    if ([identifier isEqualToString:@"showDetail"]) {
        NSLog(@"Segue Blocked");
        //Put your validation code here and return YES or NO as needed
        
        if([CLLocationManager locationServicesEnabled]==NO ||
           [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            //Location services must be enabled to view local plants
            //plantomatic will not work with out Location Services. To use this app, please go to Settings and enabled Location Services
            
            //Location services must be enabled\nto view local events
            
            [Utility showAlert:@"" message:@"Plantomatic will not work with out Location Services. To use this app, please go to Settings and enabled Location Services"];
            returnValue=NO;
        }
    }
    
    return returnValue;
}


@end
