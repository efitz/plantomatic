//
//  PlantCell.m
//  plantomatic
//
//  Created by developer on 3/7/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantCell.h"
#import "SpeciesFamily.h"
#import <QuartzCore/QuartzCore.h>

@interface PlantCell ()





//First column
@property (strong, nonatomic) IBOutlet UIView *colorView;
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

-(void) awakeFromNib
{
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
    
    NSString* imageNameForHabit=[NSString stringWithFormat:@"%@-selected.png",plant.habit];
    
    if ([plant.habit isEqualToString:@"-"]) {
        imageNameForHabit=@"Unknown-selected.png";
    }
    
    self.growthFormImgView.image=[UIImage imageNamed:imageNameForHabit];
    
    //This is not working with formula we have placed half value for making circle i.e 17
    self.colorView.layer.cornerRadius = 17;//self.colorView.frame.size.width/2 ;
    self.colorView.clipsToBounds = YES;
    self.colorView.backgroundColor=[UIColor whiteColor];
    
    /*
     Special case to replace the Flower Color descriptor:
     
     if major_group == angiosperm then display flower_color
     elseif major group == fern or bryophyte then display spore
     elseif major group == gymnosperm then display cone
     */
    
    if ([plant.classification isEqualToString:@"Angiosperms"])
    {
        // major_group == angiosperm then display flower_color
        //This is case for flower
        NSString* imageNameForFlower=[NSString stringWithFormat:@"%@-selected.png",plant.flowerColor];
        NSString* flowerColor=plant.flowerColor;
        if ([plant.flowerColor isEqualToString:@"-"]) {
            imageNameForFlower=@"Unknown-Flower-selected.png";
            flowerColor=@" -";
        }
        
        self.flowerColorImgView.image=[UIImage imageNamed:imageNameForFlower];
        [self.classificationLbl setText:[NSString stringWithFormat:@"Flower Color:%@",flowerColor]];
    }
    else if ([plant.classification isEqualToString:@"Bryophytes"]||[plant.classification isEqualToString:@"Ferns"])
    {
         //major group == fern or bryophyte then display spore
        self.flowerColorImgView.image=[UIImage imageNamed:@"spores"];
        
        [self.classificationLbl setText:plant.classification];
    }
    else if ([plant.classification isEqualToString:@"Gymnosperms"])
    {
        //major group == gymnosperm then display cone
        self.flowerColorImgView.image=[UIImage imageNamed:@"cone"];
        [self.classificationLbl setText:plant.classification];
    }
    else
    {
        ////major group == NA (not avaialble)
        //There are 23 records in "SpeciesFamily" with classification "NA"
        //We dont have image for "NA"
        //so, i m setting it nil
        self.flowerColorImgView.image=nil;
        
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
