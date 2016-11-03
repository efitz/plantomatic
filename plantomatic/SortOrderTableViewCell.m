//
//  SortOrderTableViewCell.m
//  plantomatic
//
//  Created by developer on 2/18/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import "SortOrderTableViewCell.h"

@interface SortOrderTableViewCell()
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)valueChangeAction:(id)sender;
@end

@implementation SortOrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) updateCell
{
    NSNumber *isSortOrderAscending = [[NSUserDefaults standardUserDefaults]
                                      valueForKey:@"sortOrder"];
    
    if (isSortOrderAscending.boolValue)
    {
        self.segmentControl.selectedSegmentIndex=0;
    }
    else
    {
        self.segmentControl.selectedSegmentIndex=1;
    }
    
}


- (IBAction)valueChangeAction:(id)sender
{
//    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"familiesSelected"];

    if (self.segmentControl.selectedSegmentIndex==0)
    {
        //A-Z
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"sortOrder"];
    }
    else
    {
        //Z-A
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"sortOrder"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
