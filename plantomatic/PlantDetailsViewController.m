//
//  PlantDetailsViewController.m
//  plantomatic
//
//  Created by developer on 8/17/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantDetailsViewController.h"
#import "SpeciesFamily.h"
#import <QuartzCore/QuartzCore.h>
#import "PlantPageViewController.h"
#import "plantomatic-swift.h"
#import "PlantImagesService.h"
#import "Utility.h"
#import "Constants.h"

@interface PlantDetailsViewController ()<PlantPageViewControllerDelegate,PlantImagesServiceDelegate>


//First column
@property (strong, nonatomic) IBOutlet UILabel *commonNameLbl;

//Second column
@property (strong, nonatomic) IBOutlet UIView *colorView;
@property (strong, nonatomic) IBOutlet UIImageView *flowerColorImgView;
@property (strong, nonatomic) IBOutlet UIImageView *growthFormImgView;
@property (strong, nonatomic) IBOutlet UILabel *habitLbl;
@property (strong, nonatomic) IBOutlet UILabel *classificationLbl;

@property (strong, nonatomic) IBOutlet UIPageControl* pageControl;

@property (strong, nonatomic) PlantPageViewController* plantPageViewController;

@property (strong, nonatomic) IBOutlet ReadMoreTextView *introTxtView;
@property (strong, nonatomic) IBOutlet ReadMoreTextView *descTxtView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) PlantImagesService *plantImagesService;

@end

@implementation PlantDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateWithSpeciesFamily:self.plant];
    
    self.pageControl.numberOfPages = self.assets.count;
    
    [self.pageControl addTarget:self action:@selector(didChangePageControlValue) forControlEvents:UIControlEventValueChanged];
    
    
    if (self.assets == nil) {
        self.pageControl.hidden = true;
        self.plantPageViewController.view.userInteractionEnabled = false;
    }
    
    if (self.assets.count == 1) {
//        self.pageControl.hidden = true;
        
        for (UIScrollView *view in self.plantPageViewController.view.subviews) {
            
            if ([view isKindOfClass:[UIScrollView class]]) {
                
                view.scrollEnabled = NO;
            }
        }
    }
    
    
    UIColor* color = [[UIColor alloc] initWithRed:65.0/255.0 green:149.0/255.0 blue:221.0/255.0 alpha:1.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *trimText = [[NSAttributedString alloc] initWithString:@"Read More" attributes:attrsDictionary];
    
    self.introTxtView.trimText = nil;
    self.introTxtView.attributedTrimText = trimText;
    self.introTxtView.text = @"Loading introduction ...";
    
    self.descTxtView.trimText = nil;
    self.descTxtView.attributedTrimText = trimText;
    self.descTxtView.text = @"Loading description ...";
    
    PlantImagesService *plantImagesService = [[PlantImagesService alloc] initServiceWithDelegate:self];
    self.plantImagesService = plantImagesService;
    
    [self.plantImagesService fetchIntroductionForPlant:self.plant];
    [self.plantImagesService fetchDescriptionForPlant:self.plant];

    

}

-(void) viewDidLayoutSubviews{
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    
    contentRect.size.height += 46;
    
    self.scrollView.contentSize = contentRect.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    self.plantPageViewController = (PlantPageViewController*)segue.destinationViewController;
    self.plantPageViewController.pageControlDelegate = self;
    self.plantPageViewController.assets = self.assets;
    
}


-(void) didChangePageControlValue
{
     if (self.assets.count > 1) {
         [self.plantPageViewController scrollToViewController:(int)self.pageControl.currentPage];
     }
}


-(void) updateWithSpeciesFamily:(SpeciesFamily*)plant
{
    //Second column
    
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
        [self.classificationLbl setText:[NSString stringWithFormat:@"Flower Color: %@",flowerColor]];
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
    
    
    
    //First column
    
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
    
    self.commonNameLbl.attributedText=attString;
}

#pragma mark - PlantPageViewControllerDelegate Methods

-(void) plantPageViewController:(PlantPageViewController*)plantPageViewController
             didUpdatePageCount:(int)count
{
    self.pageControl.numberOfPages = count;
}

-(void) plantPageViewController:(PlantPageViewController*)plantPageViewController
             didUpdatePageIndex:(int)index
{
    self.pageControl.currentPage = index;
}


#pragma mark - PlantImagesServiceDelegate Methods


- (void)introductionFetchOperationSucceed:(NSString*)introduction
                          isOnlyWithGenus:(BOOL)isOnlyWithGenus
{
    UIColor* color = [[UIColor alloc] initWithRed:65.0/255.0 green:149.0/255.0 blue:221.0/255.0 alpha:1.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *trimText = [[NSAttributedString alloc] initWithString:@"Read More" attributes:attrsDictionary];
    
    self.introTxtView.trimText = nil;
    self.introTxtView.attributedTrimText = trimText;

    
    //////////////
    
    UIFont* boldFont = [UIFont boldSystemFontOfSize:15.0];
    UIFont* italicFont = [UIFont italicSystemFontOfSize:15.0];
    UIFont* normalFont = [UIFont systemFontOfSize:15.0];

    UIColor* grayColor = [UIColor darkGrayColor];
    UIColor* blackColor = [UIColor blackColor];

    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString* introductionTitleString = @"Introduction";
    long stringLength = introductionTitleString.length;
    
    NSMutableAttributedString* attStringToAdd = [[NSMutableAttributedString alloc] initWithString:introductionTitleString];
    [attStringToAdd addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:blackColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    [attString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    

    
    if (isOnlyWithGenus)
    {
        //[Utility showAlert:@"Plant Introduction Found with G:" message:introduction];
        
        NSString* genusString = [NSString stringWithFormat:@"Genus: %@\n",self.plant.genus];
        stringLength = genusString.length;
        
        attStringToAdd = [[NSMutableAttributedString alloc] initWithString:genusString];
        [attStringToAdd addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, stringLength)];
        [attStringToAdd addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(0, stringLength)];
        
        [attString appendAttributedString:attStringToAdd];
    }
    else
    {
       // [Utility showAlert:@"Plant Introduction Found with G+S:" message:introduction];
    }
    
    
    stringLength = introduction.length;
    attStringToAdd = [[NSMutableAttributedString alloc] initWithString:introduction];
    [attStringToAdd addAttribute:NSFontAttributeName value:normalFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:blackColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    
    self.introTxtView.attributedText = attString;

    
}


- (void)introductionFetchOperationFail:(NSString *)errorMessage
{
//    [Utility showAlert:@"Plant Introduction Failure:" message:errorMessage];
    
    UIFont* boldFont = [UIFont boldSystemFontOfSize:15.0];
    UIFont* italicFont = [UIFont italicSystemFontOfSize:15.0];
    UIColor* grayColor = [UIColor darkGrayColor];
    UIColor* blackColor = [UIColor blackColor];

    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString* introductionTitleString = @"Introduction";
    long stringLength = introductionTitleString.length;
    NSMutableAttributedString* attStringToAdd = [[NSMutableAttributedString alloc] initWithString:introductionTitleString];
    [attStringToAdd addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:blackColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    [attString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    NSString* genusString = NO_INTRODUCTION_FOUND_MSG;
    stringLength = genusString.length;
    attStringToAdd = [[NSMutableAttributedString alloc] initWithString:genusString];
    [attStringToAdd addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    
    self.introTxtView.attributedText = attString;
}


//-(void) fetchDescriptionForPlant:(SpeciesFamily*) plant;
- (void)descriptionFetchOperationSucceed:(NSString*)description
                         isOnlyWithGenus:(BOOL)isOnlyWithGenus
{
    UIColor* color = [[UIColor alloc] initWithRed:65.0/255.0 green:149.0/255.0 blue:221.0/255.0 alpha:1.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:color
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *trimText = [[NSAttributedString alloc] initWithString:@"Read More" attributes:attrsDictionary];
    
    self.descTxtView.trimText = nil;
    self.descTxtView.attributedTrimText = trimText;
    
    
    //////////////
    
    UIFont* boldFont = [UIFont boldSystemFontOfSize:15.0];
    UIFont* italicFont = [UIFont italicSystemFontOfSize:15.0];
    UIFont* normalFont = [UIFont systemFontOfSize:15.0];
    
    UIColor* grayColor = [UIColor darkGrayColor];
    UIColor* blackColor = [UIColor blackColor];
    
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString* introductionTitleString = @"Description";
    long stringLength = introductionTitleString.length;
    
    NSMutableAttributedString* attStringToAdd = [[NSMutableAttributedString alloc] initWithString:introductionTitleString];
    [attStringToAdd addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:blackColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    [attString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    
    
    
    if (isOnlyWithGenus)
    {
        //[Utility showAlert:@"Plant Introduction Found with G:" message:introduction];
        
        NSString* genusString = [NSString stringWithFormat:@"Genus: %@\n",self.plant.genus];
        stringLength = genusString.length;
        
        attStringToAdd = [[NSMutableAttributedString alloc] initWithString:genusString];
        [attStringToAdd addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, stringLength)];
        [attStringToAdd addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(0, stringLength)];
        
        [attString appendAttributedString:attStringToAdd];
    }
    else
    {
        // [Utility showAlert:@"Plant Introduction Found with G+S:" message:introduction];
    }
    
    
    stringLength = description.length;
    attStringToAdd = [[NSMutableAttributedString alloc] initWithString:description];
    [attStringToAdd addAttribute:NSFontAttributeName value:normalFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:blackColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    
    self.descTxtView.attributedText = attString;

}

- (void)descriptionFetchOperationFail:(NSString *)errorMessage
{
    UIFont* boldFont = [UIFont boldSystemFontOfSize:15.0];
    UIFont* italicFont = [UIFont italicSystemFontOfSize:15.0];
    UIColor* grayColor = [UIColor darkGrayColor];
    UIColor* blackColor = [UIColor blackColor];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString* introductionTitleString = @"Description";
    long stringLength = introductionTitleString.length;
    NSMutableAttributedString* attStringToAdd = [[NSMutableAttributedString alloc] initWithString:introductionTitleString];
    [attStringToAdd addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:blackColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    [attString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    NSString* genusString = NO_DESCRIPTION_FOUND_MSG;
    stringLength = genusString.length;
    attStringToAdd = [[NSMutableAttributedString alloc] initWithString:genusString];
    [attStringToAdd addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, stringLength)];
    [attStringToAdd addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(0, stringLength)];
    [attString appendAttributedString:attStringToAdd];
    
    self.descTxtView.attributedText = attString;
}

@end
