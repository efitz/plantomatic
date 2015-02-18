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
{
    self.titleString=title;
    self.isSelected=isSelected;
    //@{@"title":@"Aquatic", @"selectedImage":@"", @"unselectedImage":@"", @"isSelected":@NO}
    
    self.filterLbl.text=title;
    NSString* imageName=[NSString stringWithFormat:@"%@.png",self.titleString];
    NSString* selectedImageName=[NSString stringWithFormat:@"%@-selected.png",self.titleString];


    if (isSelected)
    {
        [self.filterImageView setImage:[UIImage imageNamed:selectedImageName]];
    }
    else
    {
        [self.filterImageView setImage:[UIImage imageNamed:imageName]];
    }
    
}



@end