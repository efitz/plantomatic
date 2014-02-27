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
    
   
    /*
     //// **************************************************************************
     //example code copied from: http://trac.osgeo.org/proj/wiki/ProjAPI
     
     projPJ pj_merc, pj_latlong;
     double x =-16 , y=20.25;
     
     if (!(pj_merc = pj_init_plus("+proj=merc +ellps=clrk66 +lat_ts=33")) )
     exit(1);
     if (!(pj_latlong = pj_init_plus("+proj=latlong +ellps=clrk66")) )
     exit(1);
     x *= DEG_TO_RAD;
     y *= DEG_TO_RAD;
     pj_transform(pj_latlong, pj_merc, 1, 1, &x, &y, NULL );
     printf("%.2f\t%.2f\n", x, y);
     //// **************************************************************************
    */
    
    
    //Here is what we want to accomplish
	
	double lat=0, lon=0;
	lat = [self.latitudeTxtField.text doubleValue];
	lon = [self.longitudeTxtField.text doubleValue];
	//Need to convert the input coordinates into radians
	lat = DEGREES_TO_RADIANS(lat);
	lon = DEGREES_TO_RADIANS(lon);
    
    //Initiate the destination projection using the  Lambert Equal Area projection with proper offsets
	projPJ dst_prj = pj_init_plus("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs");
    
    //Initiate the source projection
    projPJ src_prj = pj_init_plus("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs");
    
    //To transform the data
    pj_transform(src_prj, dst_prj, 1, 1, &lon, &lat, NULL);
    
    self.xyLbl.text=[NSString stringWithFormat:@"Y=%.0f, X=%.0f", lat, lon];
    
    pj_free(src_prj);
    pj_free(dst_prj);
     
    
}
@end
