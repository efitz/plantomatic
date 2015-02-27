//
//  FilterHeaderTableViewCell.m
//  plantomatic
//
//  Created by developer on 2/26/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import "FilterHeaderTableViewCell.h"
#import "Utility.h"
#import "Constants.h"

@interface FilterHeaderTableViewCell ()

- (IBAction)resetToDefaultSettings:(id)sender;
@end

@implementation FilterHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)resetToDefaultSettings:(id)sender
{
    [Utility resetUserDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FAMILY_FILTER_CELL_NOTIFICATION object:nil];
}

@end
