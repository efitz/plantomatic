//
//  constants.h
//  plantomatic
//
//  Created by ehfitz on 2/26/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


enum FilterByValue {
    FilterByValueFamily,
    FilterByValueGenus,
    FilterByValueSpecies
};

@interface constants : NSObject


#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@end
