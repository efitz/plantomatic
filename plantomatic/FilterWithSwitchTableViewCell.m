//
//  FilterWithSwitchTableViewCell.m
//  plantomatic
//
//  Created by developer on 2/11/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import "FilterWithSwitchTableViewCell.h"

@interface FilterWithSwitchTableViewCell()

@property (strong, nonatomic) IBOutlet UISwitch *isAvaiableSwitch;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (nonatomic, readwrite) FilterType filterType;

- (IBAction)valueChangeAction:(id)sender;
@end

@implementation FilterWithSwitchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) updateCellWithFilterType:(FilterType)filterType
{
    self.filterType=filterType;
    
    if (filterType==FilterTypeCommonName)
    {
        self.titleLbl.text=@"Common Name Available";
        NSNumber *isCommonNameAvaialble = [[NSUserDefaults standardUserDefaults]
                                           valueForKey:@"isCommonNameAvailable"];
        
        [self.isAvaiableSwitch setOn:isCommonNameAvaialble.boolValue];
  
    }
    else if(filterType==FilterTypeImage)
    {
        self.titleLbl.text=@"Image Available";
        NSNumber *isImageAvailable = [[NSUserDefaults standardUserDefaults]
                                      valueForKey:@"isImageAvailable"];
        [self.isAvaiableSwitch setOn:isImageAvailable.boolValue];
    }
}

- (IBAction)valueChangeAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"familiesSelected"];
    
    if (self.filterType==FilterTypeCommonName)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isAvaiableSwitch.isOn] forKey:@"isCommonNameAvailable"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(self.filterType==FilterTypeImage)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isAvaiableSwitch.isOn] forKey:@"isImageAvailable"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FAMILY_FILTER_CELL_NOTIFICATION object:nil];

}


@end
