//
//  Utility.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    
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

+ (NSString *)getStringValueWithDict:(NSDictionary *)dict key:(NSString *)key
{
    NSString *value = [dict valueForKey:key];
    // Dictionary cannot store nil, so we don't need to test that.
    // NSNull happens when dict was created from a json response that has null set.
    if ([value isKindOfClass:[NSNull class]])
    {
        value = @"";
    }
    
    return value;
}

#pragma mark Web Related Utilities
// Consider moving this into a NSString+URLEncoding.h object
+ (NSString *)urlEncodeValue:(NSString *)value usingEncoding:(NSStringEncoding)encoding
{
    if (![value isKindOfClass:[NSString class]])
    {
        // Handles objects from dictionary that may have been other objects like NSNumber
        value = [NSString stringWithFormat:@"%@", value];
    }
    
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)value,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}


+ (int)getIntValueWithDict:(NSDictionary *)dict key:(NSString *)key;
{
    int intValue = 0;
    NSString *value = [dict valueForKey:key];
    // valueForKey may not always return a NSString, it may return something like
    // NSDecimalNumber, so calling value length may crash.
    if (![value isKindOfClass:[NSNull class]])
    {
        intValue = [value intValue];
    }
    
    return intValue;
}

+ (BOOL)isiOS7{
    
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
    
}

@end
