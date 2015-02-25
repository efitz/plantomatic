//
//  FilterCollectionViewTableViewCell.h
//  plantomatic
//
//  Created by developer on 2/10/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCollectionViewTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

-(void)updateCellForGrowthForm:(NSDictionary*)dict;
-(void)updateCellForFlowerColors:(NSDictionary*)dict;


@end
