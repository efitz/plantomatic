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
@property (strong, nonatomic) IBOutlet UITextView *infoTxtView;
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
    
    if([Utility isiOS7])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    
    NSNumber *isNeedToShowWelcome = [[NSUserDefaults standardUserDefaults]
                                     valueForKey:@"isNeedToShowWelcome"];
    
    if (isNeedToShowWelcome.boolValue) {
        self.showWelcomeScreenSwitch.on=YES;
    }
    else
    {
        self.showWelcomeScreenSwitch.on=NO;
    }
    
    NSMutableAttributedString *attributedString = [self.infoTxtView.attributedText mutableCopy];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [UIImage imageNamed:@"ocotea_logo.png"];
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSMutableAttributedString *attrStringWithImageMutable =[attrStringWithImage mutableCopy];
    //add alignment to make logo image centered in screen
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attrStringWithImageMutable addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStringWithImageMutable.length)];

    
    [attributedString appendAttributedString:attrStringWithImageMutable];
    
    /*
     Font name: Cambria
     Font name: Cambria-Italic
     Font name: Cambria-Bold
     Font name: Cambria-BoldItalic
     */
    
    UIFont* cambriaRegular=[UIFont fontWithName:@"Cambria" size:12];
    UIFont* cambriaItalic=[UIFont fontWithName:@"Cambria-Italic" size:12];
    UIFont* cambriaBold=[UIFont fontWithName:@"Cambria-Bold" size:12];
    UIFont* cambriaBoldItalic=[UIFont fontWithName:@"Cambria-BoldItalic" size:12];
    
    self.infoTxtView.attributedText=[self ApplyCustomFont:attributedString
                                                 boldFont:cambriaBold
                                               italicFont:cambriaItalic
                                               boldItalic:cambriaBoldItalic
                                              regularFont:cambriaRegular];
    
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

-(NSMutableAttributedString*) ApplyCustomFont:(NSAttributedString*)attributedText
                                     boldFont:(UIFont*)boldFont
                                   italicFont:(UIFont*)italicFont
                                   boldItalic:(UIFont*)boldItalicFont
                                  regularFont:(UIFont*)regularFont
{
    
    NSMutableAttributedString *attrib = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [attrib beginEditing];
    [attrib enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attrib.length) options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         if (value)
         {
             UIFont *oldFont = (UIFont *)value;
             NSLog(@"%@",oldFont.fontName);
             
             [attrib removeAttribute:NSFontAttributeName range:range];
             
             if([oldFont.fontName rangeOfString:@"BoldItalic"].location != NSNotFound && boldItalicFont != nil)
                 [attrib addAttribute:NSFontAttributeName value:boldItalicFont range:range];
             else if([oldFont.fontName rangeOfString:@"Italic"].location != NSNotFound && italicFont != nil)
                 [attrib addAttribute:NSFontAttributeName value:italicFont range:range];
             else if([oldFont.fontName rangeOfString:@"Bold"].location != NSNotFound && boldFont != nil)
                 [attrib addAttribute:NSFontAttributeName value:boldFont range:range];
             else if(regularFont != nil)
                 [attrib addAttribute:NSFontAttributeName value:regularFont range:range];
         }
     }];
    [attrib endEditing];
    
    return attrib;
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
