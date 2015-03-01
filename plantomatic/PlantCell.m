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
    
    //ChunkFive 18
    //system italic 18
    //system bold 14
    
    UIFont *chunkFiveFont=[UIFont fontWithName:@"ChunkFive" size:18];
    UIFont *italicSystemFont=[UIFont italicSystemFontOfSize:18];
    UIFont *boldSystemFont=[UIFont boldSystemFontOfSize:14];
    UIColor *fontColor=[UIColor blackColor];
    
    
    NSString* commonName=plant.commonName;
    NSString* genusSpecies=[NSString stringWithFormat:@"%@ %@",plant.genus,plant.species];
    NSString* family=plant.family;
    
    NSInteger commonNameLength=[commonName length];
    NSInteger genusSpeciesLength=[genusSpecies length];
    NSInteger familyLength=[family length];
    
    
    //ChunkFive 18
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:commonName];
    [attString addAttribute:NSFontAttributeName value:chunkFiveFont range:NSMakeRange(0, commonNameLength)];
    [attString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(0, commonNameLength)];
    
    //system italic 18
    NSMutableAttributedString *genusSpeciesAttributtedString=[[NSMutableAttributedString alloc] initWithString:genusSpecies];
    [genusSpeciesAttributtedString addAttribute:NSFontAttributeName value:italicSystemFont range:NSMakeRange(0, genusSpeciesLength)];
    [genusSpeciesAttributtedString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(0, genusSpeciesLength)];


    //system bold 14
    NSMutableAttributedString *familyattributedString=[[NSMutableAttributedString alloc] initWithString:family];
    [familyattributedString addAttribute:NSFontAttributeName value:boldSystemFont range:NSMakeRange(0, familyLength)];
    [familyattributedString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(0, familyLength)];
    
    NSMutableAttributedString *simpleCr = [[NSMutableAttributedString alloc] initWithString: @"\n"];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineHeightMultiple:0.5];

    
    NSMutableAttributedString *cr = [[NSMutableAttributedString alloc] initWithString: @"\n"];
    [cr addAttribute:NSParagraphStyleAttributeName
                                          value:style
                                          range:NSMakeRange(0, @"\n".length)];
    
    [attString appendAttributedString:simpleCr];
    [attString appendAttributedString:cr];
    [attString appendAttributedString:genusSpeciesAttributtedString];
    [attString appendAttributedString:simpleCr];
    [attString appendAttributedString:cr];
    [attString appendAttributedString:familyattributedString];


    
//    NSInteger strLength = [attString length];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    [style setLineHeightMultiple:0.92];
//    [attString addAttribute:NSParagraphStyleAttributeName
//                      value:style
//                      range:NSMakeRange(0, strLength)];
    
    self.commonNameLbl.attributedText=attString;
    
    
    
//    [self.commonNameLbl setText:plant.commonName];
//    [self.genusSpeciesLbl setText:[NSString stringWithFormat:@"%@ %@",plant.genus,plant.species]];
//    [self.familyLbl setText:[NSString stringWithFormat:@"%@ ",plant.family]];
   
    
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
