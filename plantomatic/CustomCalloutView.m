//
//  CustomCalloutView.m
//  plantomatic
//
//  Created by developer on 8/8/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import "CustomCalloutView.h"


@implementation CustomCalloutView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)updateCellWithDistanceString:(NSString*)distance addressString:(NSString*)address
{
    self.addressLbl.text = address;
   self.distanceLbl.text = distance;
}



@end
