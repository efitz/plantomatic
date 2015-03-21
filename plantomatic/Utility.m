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


+(void) initializeUserDefaults
{
    NSNumber *isCommonNameAvaialble = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:@"isCommonNameAvailable"];
    
    if (isCommonNameAvaialble==nil)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCommonNameAvailable"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSNumber *isImageAvailable = [[NSUserDefaults standardUserDefaults]
                                  valueForKey:@"isImageAvailable"];
    
    if (isImageAvailable==nil)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isImageAvailable"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *isSortOrderAscending = [[NSUserDefaults standardUserDefaults]
                                      valueForKey:@"sortOrder"];
    
    if (isSortOrderAscending==nil)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"sortOrder"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    NSMutableDictionary *flowerColorsDictionary = [[NSUserDefaults standardUserDefaults]
                                                   valueForKey:@"flowerColorsDictionary"];
    
    if (flowerColorsDictionary==nil)
    {
        flowerColorsDictionary=[@{@"Red":@{@"isSelected":@NO},
                                  @"Pink":@{@"isSelected":@NO},
                                  @"Violet":@{@"isSelected":@NO},
                                  @"Purple": @{@"isSelected":@NO},
                                  @"Blue":@{@"isSelected":@NO},
                                  @"Green": @{ @"isSelected":@NO},
                                  @"Yellow":@{@"isSelected":@NO},
                                  @"Orange":@{@"isSelected":@NO},
                                  @"Brown":@{@"isSelected":@NO},
                                  @"Gray":@{@"isSelected":@NO},
                                  @"Black":@{@"isSelected":@NO},
                                  @"White":@{@"isSelected":@NO},
                                  @"Unknown-Flower":@{@"isSelected":@NO}
                                  } mutableCopy];
        
        [[NSUserDefaults standardUserDefaults] setObject:flowerColorsDictionary forKey:@"flowerColorsDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSMutableDictionary *growthFormDictionary = [[NSUserDefaults standardUserDefaults]
                                                 valueForKey:@"growthFormDictionary"];
    
    if (growthFormDictionary==nil)
    {
        growthFormDictionary=[@{@"Aquatic":@{@"isSelected":@NO},
                                @"Bryophyte":@{@"isSelected":@NO},
                                @"Cactus":@{@"isSelected":@NO},
                                @"Epiphyte":@{@"isSelected":@NO},
                                @"Fern": @{@"isSelected":@NO},
                                @"Grass":@{@"isSelected":@NO},
                                @"Herb": @{ @"isSelected":@NO},
                                @"Parasite":@{@"isSelected":@NO},
                                @"Shrub":@{@"isSelected":@NO},
                                @"Tree":@{@"isSelected":@NO},
                                @"Vine":@{@"isSelected":@NO},
                                @"Unknown":@{@"isSelected":@NO}} mutableCopy];
        
        [[NSUserDefaults standardUserDefaults] setObject:growthFormDictionary forKey:@"growthFormDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSMutableArray* familiesSelected=[[NSUserDefaults standardUserDefaults] objectForKey:@"familiesSelected"];
    
    if (familiesSelected==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"familiesSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSMutableArray* sortColumns=[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"];
    
    if (sortColumns==nil) {
        ;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray arrayWithObjects:@"Genus", nil] forKey:@"sortColumns"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(void) resetUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCommonNameAvailable"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isImageAvailable"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"sortOrder"];
    
    NSMutableDictionary *flowerColorsDictionary=[@{@"Red":@{@"isSelected":@NO},
                                                   @"Pink":@{@"isSelected":@NO},
                                                   @"Violet":@{@"isSelected":@NO},
                                                   @"Purple": @{@"isSelected":@NO},
                                                   @"Blue":@{@"isSelected":@NO},
                                                   @"Green": @{ @"isSelected":@NO},
                                                   @"Yellow":@{@"isSelected":@NO},
                                                   @"Orange":@{@"isSelected":@NO},
                                                   @"Brown":@{@"isSelected":@NO},
                                                   @"Gray":@{@"isSelected":@NO},
                                                   @"Black":@{@"isSelected":@NO},
                                                   @"White":@{@"isSelected":@NO},
                                                   @"Unknown-Flower":@{@"isSelected":@NO}
                                                   } mutableCopy];
    
    [[NSUserDefaults standardUserDefaults] setObject:flowerColorsDictionary forKey:@"flowerColorsDictionary"];
    
    NSMutableDictionary *growthFormDictionary=[@{@"Aquatic":@{@"isSelected":@NO},
                                                 @"Bryophyte":@{@"isSelected":@NO},
                                                 @"Cactus":@{@"isSelected":@NO},
                                                 @"Epiphyte":@{@"isSelected":@NO},
                                                 @"Fern": @{@"isSelected":@NO},
                                                 @"Grass":@{@"isSelected":@NO},
                                                 @"Herb": @{ @"isSelected":@NO},
                                                 @"Parasite":@{@"isSelected":@NO},
                                                 @"Shrub":@{@"isSelected":@NO},
                                                 @"Tree":@{@"isSelected":@NO},
                                                 @"Vine":@{@"isSelected":@NO},
                                                 @"Unknown":@{@"isSelected":@NO}} mutableCopy];
    
    [[NSUserDefaults standardUserDefaults] setObject:growthFormDictionary forKey:@"growthFormDictionary"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"familiesSelected"];

    [[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray arrayWithObjects:@"Genus", nil] forKey:@"sortColumns"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(BOOL)isAppUsingDefaultSettings
{
    BOOL isUsingDefaultValues=YES;
    
    BOOL isNeedToCheckFurther=YES;
    
    //default is NO
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isCommonNameAvailable"] boolValue])
    {
        isNeedToCheckFurther=NO;
        isUsingDefaultValues=NO;
    }
    
    //default is NO
    if (isNeedToCheckFurther && [[[NSUserDefaults standardUserDefaults] valueForKey:@"isImageAvailable"] boolValue])
    {
        isNeedToCheckFurther=NO;
        isUsingDefaultValues=NO;
    }
    
    //default is YES
    if (isNeedToCheckFurther && [[[NSUserDefaults standardUserDefaults] valueForKey:@"sortOrder"] boolValue]==NO)
    {
        isNeedToCheckFurther=NO;
        isUsingDefaultValues=NO;
    }
    
    
    
    if (isNeedToCheckFurther)
    {
        NSMutableDictionary *flowerColorsDictionary=[[NSUserDefaults standardUserDefaults] valueForKey:@"flowerColorsDictionary"];
        NSArray* keysArray=[flowerColorsDictionary allKeys];
        
        for (NSString* key in keysArray)
        {
            NSMutableDictionary* dictionary=[[flowerColorsDictionary valueForKey:key] mutableCopy];
            
            if ([[dictionary valueForKey:@"isSelected"] boolValue])
            {
                isNeedToCheckFurther=NO;
                isUsingDefaultValues=NO;
                break;
            }
        }
    }
    
    
    if (isNeedToCheckFurther)
    {
        NSMutableDictionary *growthFormDictionary=[[NSUserDefaults standardUserDefaults] valueForKey:@"growthFormDictionary"];
        NSArray* keysArray=[growthFormDictionary allKeys];
        
        for (NSString* key in keysArray)
        {
            NSMutableDictionary* dictionary=[[growthFormDictionary valueForKey:key] mutableCopy];
            
            if ([[dictionary valueForKey:@"isSelected"] boolValue])
            {
                isNeedToCheckFurther=NO;
                isUsingDefaultValues=NO;
                break;
            }
        }
    }

    if (isNeedToCheckFurther && [[[NSUserDefaults standardUserDefaults] valueForKey:@"familiesSelected"] count]>0)
    {
        isNeedToCheckFurther=NO;
        isUsingDefaultValues=NO;
    }
    
    if (isNeedToCheckFurther && [[[NSUserDefaults standardUserDefaults] valueForKey:@"sortColumns"] count]>0)
    {
        NSMutableArray* sortColumnsSelected=[[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"] mutableCopy];
        
        if ([sortColumnsSelected count]>0)
        {
       
            NSString* sortColumn=[sortColumnsSelected objectAtIndex:0u];

            if (![sortColumn isEqualToString:@"Genus"]) {
                isNeedToCheckFurther=NO;
                isUsingDefaultValues=NO;
            }
        }
    }
    
    
    return isUsingDefaultValues;
}



+(BOOL)isAllGrowthFormsSelected
{
    BOOL isAllSelected=YES;
    
    NSMutableDictionary *growthFormDictionary=[[NSUserDefaults standardUserDefaults] valueForKey:@"growthFormDictionary"];
    NSArray* keysArray=[growthFormDictionary allKeys];
    
    for (NSString* key in keysArray)
    {
        NSMutableDictionary* dictionary=[[growthFormDictionary valueForKey:key] mutableCopy];
        
        if ([[dictionary valueForKey:@"isSelected"] boolValue]==NO)
        {
            isAllSelected=NO;
            break;
        }
    }

    
    return isAllSelected;
}


+(BOOL)isAllFlowersSelected
{
    BOOL isAllSelected=YES;
    
    
    NSMutableDictionary *flowerColorsDictionary=[[NSUserDefaults standardUserDefaults] valueForKey:@"flowerColorsDictionary"];
    NSArray* keysArray=[flowerColorsDictionary allKeys];
    
    for (NSString* key in keysArray)
    {
        NSMutableDictionary* dictionary=[[flowerColorsDictionary valueForKey:key] mutableCopy];
        
        if ([[dictionary valueForKey:@"isSelected"] boolValue]==NO)
        {
            isAllSelected=NO;
            break;
        }
    }

    
    return isAllSelected;
}


+ (void) logFontNames
{
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
}

@end
