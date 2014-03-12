//
//  PlantCell.h
//  plantomatic
//
//  Created by developer on 3/7/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlantCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *familyLbl;
@property (strong, nonatomic) IBOutlet UILabel *classificationLbl;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;


@end
