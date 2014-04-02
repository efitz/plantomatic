//
//  PlantCollectionViewCell.h
//  plantomatic
//
//  Created by developer on 4/2/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.

#import "CBetterCollectionViewCell.h"

@class CReflectionView;

@interface PlantCollectionViewCell : CBetterCollectionViewCell
@property (readwrite, nonatomic, weak) IBOutlet UIImageView *imageView;
@property (readwrite, nonatomic, weak) IBOutlet CReflectionView *reflectionImageView;
@end
