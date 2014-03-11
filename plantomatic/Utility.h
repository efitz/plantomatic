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
+(void) showAlert:(NSString *) title message:(NSString *) msg;
+(BOOL) isNumeric:(NSString *)s;

@end
