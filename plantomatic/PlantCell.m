//
//  PlantCell.m
//  plantomatic
//
//  Created by developer on 3/7/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantCell.h"
#import "SpeciesFamily.h"

@interface PlantCell ()





//First column
@property (strong, nonatomic) IBOutlet UIImageView *flowerColorImgView;
@property (strong, nonatomic) IBOutlet UIImageView *growthFormImgView;
@property (strong, nonatomic) IBOutlet UILabel *habitLbl;
@property (strong, nonatomic) IBOutlet UILabel *classificationLbl;

//second column
@property (strong, nonatomic) IBOutlet UILabel *commonNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *genusSpeciesLbl;
@property (strong, nonatomic) IBOutlet UILabel *familyLbl;

//third column
@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *thirdColumnWidthConstriant;

@end

@implementation PlantCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) updateWithSpeciesFamily:(SpeciesFamily*)plant
{
    /*
    [[self titleLbl] setText:[NSString stringWithFormat:@"%@ %@",plant.genus,plant.species]];
    [[self familyLbl] setText:[NSString stringWithFormat:@"%@ ",plant.family]];
    [[self classificationLbl] setText:[NSString stringWithFormat:@"%@ ",plant.classification]];
    [[self habitLbl] setText:[NSString stringWithFormat:@"%@ ",plant.habit]];
    
    
    NSString* imageName=[NSString stringWithFormat:@"%@_classification.png", plant.classification];
    [self.imgView setImage:[UIImage imageNamed:imageName]];
    self.imgView.contentMode=UIViewContentModeScaleAspectFit;
    
    
    if ([plant.isImageAvailabe isEqualToString:@"TRUE"]) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else
    {
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
*/
    
    //First column
    
    NSString* imageNameForHabit=[NSString stringWithFormat:@"%@.png",plant.habit];
    
    if ([plant.habit isEqualToString:@"-"]) {
        imageNameForHabit=@"Unknown.png";
    }
    
    self.growthFormImgView.image=[UIImage imageNamed:imageNameForHabit];
    
    if ([plant.classification isEqualToString:@"Angiosperms"])
    {
        //This is case for flower
        NSString* imageNameForFlower=[NSString stringWithFormat:@"%@.png",plant.flowerColor];
        NSString* flowerColor=plant.flowerColor;
        if ([plant.flowerColor isEqualToString:@"-"]) {
            imageNameForFlower=@"Unknown-Flower.png";
            flowerColor=@" -";
        }
        
        self.flowerColorImgView.image=[UIImage imageNamed:imageNameForFlower];
        [self.classificationLbl setText:[NSString stringWithFormat:@"Flower Color:%@",flowerColor]];
    }
    else
    {
        NSString* imageNameForFlower=[NSString stringWithFormat:@"%@_classification.png", plant.classification];
        self.flowerColorImgView.image=[UIImage imageNamed:imageNameForFlower];
        
        [self.classificationLbl setText:plant.classification];
    }
    
    
    
    
    
    [self.habitLbl setText:[NSString stringWithFormat:@"%@ ",plant.habit]];

    
    
    //second column
    [self.commonNameLbl setText:plant.commonName];
    [self.genusSpeciesLbl setText:[NSString stringWithFormat:@"%@ %@",plant.genus,plant.species]];
    [self.familyLbl setText:[NSString stringWithFormat:@"%@ ",plant.family]];
   
    
    //third column
    
    if ([plant.isImageAvailabe isEqualToString:@"TRUE"]) {
        self.imgView.hidden=NO;
        self.thirdColumnWidthConstriant.constant=30;
    }
    else
    {
        self.imgView.hidden=YES;
        self.thirdColumnWidthConstriant.constant=0;
    }
    
}


@end
