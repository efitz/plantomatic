//
//  Utility.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"

@implementation Utility

+(NSString *) getDatabasePath
{
    
    NSURL *storeUrl = [[NSBundle mainBundle] URLForResource:@"PlantoMaticDB" withExtension:@"sqlite"];

    return storeUrl.absoluteString;
    
    //return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PlantoMaticDB.sqlite"];

//    NSString *databasePath = [(AppDelegate *)[[UIApplication sharedApplication] delegate] databasePath];
//    
//    return databasePath;
}


+(CLLocation *) getCurrentLocation
{
    CLLocation* currentLocation=[(AppDelegate *)[[UIApplication sharedApplication] delegate] currentLocation];
    return currentLocation;
}


+(void) showAlert:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    
    [alert show];
}


@end
