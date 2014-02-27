//
//  FMDBDataAccess.h
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBDataAccess : NSObject


-(NSMutableArray *) getPlantsForY:(int)y
                             andX:(int)x;

@end
