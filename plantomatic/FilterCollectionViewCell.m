//
//  FilterCollectionViewCell.m
//  plantomatic
//
//  Created by developer on 2/10/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import "FilterCollectionViewCell.h"


@interface FilterCollectionViewCell()

@property (strong, nonatomic) IBOutlet UIImageView *filterImageView;
@property (strong, nonatomic) IBOutlet UILabel *filterLbl;

@property (nonatomic, strong) NSString* titleString;
@property (nonatomic, readwrite) BOOL isSelected;

@end

@implementation FilterCollectionViewCell

-(void) updateCellWithTitle:(NSString*)title
                 isSelected:(BOOL)isSelected
            isForGrowthForm:(BOOL)isForGrowthForm
{
    self.titleString=title;
    self.isSelected=isSelected;
    
    NSString* imageName=[NSString stringWithFormat:@"%@.png",self.titleString];
    NSString* selectedImageName=[NSString stringWithFormat:@"%@-selected.png",self.titleString];

    if (isForGrowthForm==NO && [title isEqualToString:@"Unknown-Flower"]==NO )
    {
        imageName=@"flower_unselected";
    }
    
    if (isForGrowthForm==NO && [title isEqualToString:@"Unknown-Flower"]==YES) {
        self.titleString=@"Unknown";

    }
    
    self.filterLbl.text=self.titleString;


   
    
    if (isSelected)
    {
        [self.filterImageView setImage:[UIImage imageNamed:selectedImageName]];
        //Make the font bold when selected
        self.filterLbl.font=[UIFont boldSystemFontOfSize:12];
        self.filterLbl.textColor=[UIColor blackColor];
    }
    else
    {
        [self.filterImageView setImage:[UIImage imageNamed:imageName]];

        //Make the font normal when unselected
        self.filterLbl.font=[UIFont systemFontOfSize:12];
        self.filterLbl.textColor=[UIColor grayColor];
    }
    
}



@end
