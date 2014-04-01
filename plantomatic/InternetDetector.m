//
//  InternetDetector.m
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "InternetDetector.h"
#import "Reachability.h"

static InternetDetector *sharedManager = nil;

@implementation InternetDetector
@synthesize internetActive;
@synthesize hostActive;


+ (InternetDetector *) sharedManager
{
	@synchronized(self)
    {
        if (sharedManager == nil){
			sharedManager = [[InternetDetector alloc] init];
            [sharedManager startNetworkDetection];
		}
    }
    return sharedManager;
}


-(void) startNetworkDetection
{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostname: @"http://google.com/"];
    [hostReachable startNotifier];
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            DLog(@"The internet is down.");
            self.internetActive = NO;
            break;
            
        }
        case ReachableViaWiFi:
        {
            DLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            //            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //            [delegate updateUserActivityOnWeb];
            break;
        }
        case ReachableViaWWAN:
        {
            DLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    
    {
        case NotReachable:
        {
            DLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
            
        }
        case ReachableViaWiFi:
        {
            DLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            DLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
            
        }
    }
}


+ (BOOL) isNetAvailable
{
    return [[InternetDetector sharedManager] internetActive];
}



@end
