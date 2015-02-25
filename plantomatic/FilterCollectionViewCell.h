//
//  FilterCollectionViewCell.h
//  plantomatic
//
//  Created by developer on 2/10/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCollectionViewCell : UICollectionViewCell

-(void) updateCellWithTitle:(NSString*)title
                 isSelected:(BOOL)isSelected;


@end
