//
//  InfoViewController.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "InfoViewController.h"
#import "Utility.h"
#include "proj_api.h"
#import "Constants.h"


@interface InfoViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *showWelcomeScreenSwitch;
@property (strong, nonatomic) IBOutlet UILabel *latLongYXLbl;
@end

@implementation InfoViewController

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
    self.navigationController.navigationBar.topItem.title = @"Back";
    
    
    NSNumber *isNeedToShowWelcome = [[NSUserDefaults standardUserDefaults]
                                     valueForKey:@"isNeedToShowWelcome"];
    
    if (isNeedToShowWelcome.boolValue) {
        self.showWelcomeScreenSwitch.on=YES;
    }
    else
    {
        self.showWelcomeScreenSwitch.on=NO;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    CLLocation *currentLocation=[Utility getCurrentLocation];
    
    double lat=currentLocation.coordinate.latitude, lon=currentLocation.coordinate.longitude;
	//Need to convert the input coordinates into radians
	lat = DEGREES_TO_RADIANS(lat);
	lon = DEGREES_TO_RADIANS(lon);
    
    //Initiate the destination projection using the  Lambert Equal Area projection with proper offsets
	projPJ dst_prj = pj_init_plus("+proj=laea +lat_0=15 +lon_0=-80 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0");
    
    //Initiate the source projection
    projPJ src_prj = pj_init_plus("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs");
    
    //To transform the data
    pj_transform(src_prj, dst_prj, 1, 1, &lon, &lat, NULL);
    double X=0,Y=0,resolution=100000, corner_x=-5261554, corner_y=7165012;
	
    X = floor((lon - corner_x)/resolution + 1); //units are in meters so we need to convert output 100kM grid
	Y = floor(((lat - corner_y)/resolution * -1) + 1); //units are in meters so we need to convert output 100kM grid

    
    self.latLongYXLbl.text=[NSString stringWithFormat:@"Lat=%.6f, Lon=%.6f\rGrid: Y=%.0f, X=%.0f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, Y, X];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChangeForWelcomeScreenAction:(id)sender {
    
    BOOL boolValueToSet=NO;
    
    if ( self.showWelcomeScreenSwitch.on) {
        boolValueToSet=YES;
    }
    else
    {
        boolValueToSet=NO;
    }
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSNumber numberWithBool:boolValueToSet] forKey:@"isNeedToShowWelcome"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
