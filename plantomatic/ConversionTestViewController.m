//
//  ViewController.m
//  plantomatic
//
//  Created by ehfitz on 2/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "ConversionTestViewController.h"
#import "constants.h"
#include "proj_api.h"

@interface ConversionTestViewController ()

@property (strong, nonatomic) IBOutlet UITextField *latitudeTxtField;
@property (strong, nonatomic) IBOutlet UITextField *longitudeTxtField;
@property (strong, nonatomic) IBOutlet UILabel *xyLbl;
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI));

- (IBAction)convertIntoXY:(id)sender;

@end

@implementation ConversionTestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.xyLbl.text=@"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 
 To initiate the  Lambert Equal Area projection
 dst_prj = pj_init_plus("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
 
 Initiate the source projection
 src_prj = pj_init_plus(+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
 
 
 To transform the data
 pj_transform(src_prj, dst_prj, n*, 1*, x, y, z*)
 
 */



- (IBAction)convertIntoXY:(id)sender {


	double lat = [self.latitudeTxtField.text doubleValue];
	double lon = [self.longitudeTxtField.text doubleValue];
	//double lat=32.243065, lon=-110.927750;
	
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
	
    X = round((lon - corner_x)/resolution + 1); //units are in meters so we need to convert output 100kM grid
	Y = round(((lat - corner_y)/resolution * -1) + 1);
	
	/*
	 Here is test data with example input and output
	 1) 42.337302, -71.227067 column 61, row 42, 2117
	 2) 43.478256, -110.763924 column 28, row 38, 2263 species
	 3) 26.363909, -80.131706 column 53, row 60, 1087
	 4) 32.243065, -110.927750 column 24, row 50, 3704 species
	 */
    
    self.xyLbl.text=[NSString stringWithFormat:@"Y=%.0f, X=%.0f", X, Y];
    
    pj_free(src_prj);
    pj_free(dst_prj);
     
    
}
@end
