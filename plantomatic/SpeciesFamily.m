//
//  SpeciesFamily.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "SpeciesFamily.h"

@implementation SpeciesFamily

- (NSString *)description
{
    return [NSString stringWithFormat:@"%i, %@, %@, %@ %@, %@",self.spID,self.family, self.genus, self.species, self.classification, self.habit];;
}


@end
