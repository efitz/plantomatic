//
//  Utility.h
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Utility : NSObject


+(NSString *) getDatabasePath;
+(CLLocation *) getCurrentLocation;
+(BOOL) isUserHaveSelectedAnyLocation;
+(void) showAlert:(NSString *) title message:(NSString *) msg;
+(BOOL) isNumeric:(NSString *)s;

+ (NSString *)getStringValueWithDict:(NSDictionary *)dict key:(NSString *)key;
+ (NSString *)urlEncodeValue:(NSString *)value usingEncoding:(NSStringEncoding)encoding;
+ (int)getIntValueWithDict:(NSDictionary *)dict key:(NSString *)key;

+ (BOOL)isiOS7;


+(void) initializeUserDefaults;

+(void) resetUserDefaults;

+(BOOL)isAppUsingDefaultSettings;

+(BOOL)isAllGrowthFormsSelected;

+(BOOL)isAllFlowersSelected;

+ (void) logFontNames;

@end
