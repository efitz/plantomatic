//
//  PlantomaticAnnotation.m
//  plantomatic
//
//  Created by developer on 8/8/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantomaticAnnotation.h"

@implementation PlantomaticAnnotation


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self)
    {
        self.coordinate = coordinate;
    }
    return self;
}

@end
