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



+(BOOL) isNumeric:(NSString *)s
{
    NSScanner *sc = [NSScanner scannerWithString: s];
    // We can pass NULL because we don't actually need the value to test
    // for if the string is numeric. This is allowable.
    if ( [sc scanFloat:NULL] )
    {
        // Ensure nothing left in scanner so that "42foo" is not accepted.
        // ("42" would be consumed by scanFloat above leaving "foo".)
        return [sc isAtEnd];
    }
    // Couldn't even scan a float :(
    return NO;
}



@end
