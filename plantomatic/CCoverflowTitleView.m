//
//  CCoverflowTitleView.m
//  plantomatic
//
//  Created by developer on 4/2/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.


#import "CCoverflowTitleView.h"
#import "GAITrackedViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"

@implementation CCoverflowTitleView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;
{
    //Google Analytics manual view tracking
    //id tracker = [[GAI sharedInstance] defaultTracker];
    //[tracker set:kGAIScreenName
    //       value:@"Image Carousel View"];
    //[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

@end
