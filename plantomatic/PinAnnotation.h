//
//  PinAnnotation.h
//  CustomCalloutSample
//
//  Created by tochi on 11/05/17.
//  Copyright 2011 aguuu,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CalloutAnnotation.h"


@interface PinAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;

//plantomatic specific
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString* distance;

@property (nonatomic, strong) CalloutAnnotation *calloutAnnotation;

@end
