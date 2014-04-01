//
//  InternetDetector.h
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface InternetDetector : NSObject
{
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
    BOOL hostActive;
}

@property(nonatomic, readwrite) BOOL internetActive;
@property(nonatomic, readwrite) BOOL hostActive;

+ (InternetDetector *) sharedManager;
-(void) startNetworkDetection;
+ (BOOL) isNetAvailable;
@end
