//
//  CustomCalloutView.h
//  plantomatic
//
//  Created by developer on 8/8/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CustomCalloutView : MKAnnotationView

@property (strong, nonatomic) IBOutlet UILabel *distanceLbl;
@property (strong, nonatomic) IBOutlet UILabel *addressLbl;


-(void)updateCellWithDistanceString:(NSString*)distance addressString:(NSString*)address;

@end
