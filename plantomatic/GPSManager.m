//
//  GPSManager.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "GPSManager.h"

#ifndef SIMULATE_LOCATION_STATUS
#define SIMULATE_LOCATION_STATUS 0 //use 1 for simulating location and 1 for using device generated location
#define SIMULATE_LOCATION_LATITUDE 31.30078400
#define SIMULATE_LOCATION_LONGITUDE 74.21721700
#endif

@interface GPSManager()
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, readwrite) BOOL enabled;
@property (nonatomic, retain) CLLocation *lastLocation;
@property (assign) id delegate;
@property (assign) SEL selCallCompletaion;
@property (assign) SEL selCallFailure;

@property (nonatomic, readwrite) BOOL isLocationTrackingDisabled;


-(void) callTarget:(id)target Selector:(SEL)selector WithObject:(id)object;
@end

static GPSManager *gpsManagerInstance = nil;

@implementation GPSManager
@synthesize locationManager = _locationManager;
@synthesize enabled = _enabled;
@synthesize lastLocation = _lastLocation;
@synthesize delegate = _delegate;
@synthesize	selCallCompletaion = _selCallCompletaion;
@synthesize selCallFailure = _selCallFailure;
@synthesize isLocationTrackingDisabled=_isLocationTrackingDisabled;

+ (GPSManager *)getInstance {
    @synchronized (self) {
        if (gpsManagerInstance == nil) {
            gpsManagerInstance = [[GPSManager alloc] initGPSManager];
        }
    }
    return gpsManagerInstance;
}

- (id)initGPSManager {
    self = [super init];
    
    if (self != nil) {
        
        CLLocationManager *tempLocationManager = [[CLLocationManager alloc] init];
        self.locationManager = tempLocationManager;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.locationManager.distanceFilter = 0.0f;
        self.locationManager.delegate =self;
    }
    return self;
}

- (void)start {
    [self.locationManager startUpdatingLocation];
    self.enabled = YES;
}

- (void)stop {
    [self.locationManager stopUpdatingLocation];
    self.enabled = NO;
}

- (void)dealloc {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    
    _locationManager = nil;
    
    _delegate=nil;
    
}


-(void) registerForCurrentLocationUpdatesWithDelegate:(id)delegate completionCallSelector:(SEL) callCompleteSelector failureCallselector:(SEL) callFailSelector
{
    self.delegate=delegate;
    self.selCallCompletaion=callCompleteSelector;
    self.selCallFailure=callFailSelector;
    [self start];
}

-(void) unregisterForCurrentLocationUpdates
{
    self.delegate=nil;
    [self stop];
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    // discard invalid and expired updates
    self.isLocationTrackingDisabled=NO;
    
    
	int age = (int) [[self.lastLocation timestamp] timeIntervalSinceNow];
	if (age > 60000) { //if last location was more than 1 min old use new location anyway
		self.lastLocation = newLocation;
        
	} else if (newLocation.horizontalAccuracy > self.lastLocation.horizontalAccuracy) {
        self.lastLocation = newLocation;
    }
    
    
    if (SIMULATE_LOCATION_STATUS) {
        CLLocation* newLocationTemp=[[CLLocation alloc] initWithLatitude:SIMULATE_LOCATION_LATITUDE longitude:SIMULATE_LOCATION_LONGITUDE] ;
        [self callTarget:self.delegate Selector:self.selCallCompletaion WithObject:newLocationTemp];
    }
    else
    {
        [self callTarget:self.delegate Selector:self.selCallCompletaion WithObject:self.lastLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorLocationUnknown) {
        
    }
    
    
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) {
        // The user denied your app access to location information.
        self.isLocationTrackingDisabled=YES;
    }
    
    NSLog(@"LocationManager->Error Occured: %@", error);
    [self callTarget:self.delegate Selector:self.selCallFailure WithObject:[error description]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status==kCLAuthorizationStatusAuthorized) {
        //app is authoried to use location, go ahead
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoAHeadToUseLocationsNotification" object:nil];
    }
}


-(BOOL) isUserDisabledLocationTracking
{
    return self.isLocationTrackingDisabled;
}


#pragma mark -
#pragma mark Webservice Response Delegate Methods

-(void) callTarget:(id)target Selector:(SEL)selector WithObject:(id)object
{
	NSLog(@"Call completed .... ");
	if(target != nil && selector != nil)
	{
		if([target respondsToSelector:selector])
		{
			//[target performSelector:selector withObject:object];
            [target performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
		}
	}
}



@end
