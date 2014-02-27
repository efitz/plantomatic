//
//  GPSManager.h
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GPSManager : NSObject<CLLocationManagerDelegate>

+ (GPSManager *)getInstance;

-(void) registerForCurrentLocationUpdatesWithDelegate:(id)delegate completionCallSelector:(SEL) callCompleteSelector failureCallselector:(SEL) callFailSelector;

-(void) unregisterForCurrentLocationUpdates;

-(BOOL) isUserDisabledLocationTracking;

@end
