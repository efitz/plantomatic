//
//  FilterCollectionViewTableViewCell.m
//  plantomatic
//
//  Created by developer on 2/10/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import "FilterCollectionViewTableViewCell.h"
#import "FilterCollectionViewCell.h"
#import "Constants.h"


@interface FilterCollectionViewTableViewCell()<UICollectionViewDataSource, UICollectionViewDelegate>

//@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableDictionary* filterValuesDictionary;

@property (nonatomic, readwrite) BOOL isForGrowthForm;

@property (nonatomic, strong) IBOutlet UILabel* titleLbl;

@end

@implementation FilterCollectionViewTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateCellForGrowthForm:(NSMutableDictionary*)dict
{
    self.titleLbl.text=@"Growth Form";
    
    self.isForGrowthForm=YES;
    self.filterValuesDictionary=dict;
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    
    [self.collectionView reloadData];
}

-(void)updateCellForFlowerColors:(NSMutableDictionary*)dict
{
    self.titleLbl.text=@"Flower Colors";

    self.isForGrowthForm=NO;
    self.filterValuesDictionary=dict;
    
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    
    [self.collectionView reloadData];
}


#pragma mark - UICollectionView DataSource and Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.filterValuesDictionary allKeys].count ;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCollectionViewCell" forIndexPath:indexPath];
    
    NSLog(@"Cell Frame : %@", NSStringFromCGRect(cell.frame));
    
//    NSArray* keysArray=[[self.filterValuesDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSArray* keysArray=nil;
    
    if (self.isForGrowthForm)
    {
        keysArray=GROWTH_FORM;
    }
    else
    {
        keysArray=FLOWER_COLORS;
    }
    
    
    NSString* key=[keysArray objectAtIndex:indexPath.row];
    NSMutableDictionary* dictionary=[self.filterValuesDictionary valueForKey:key];
    NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
    [cell updateCellWithTitle:key isSelected:isSelected.boolValue];
    
    CALayer *layer = [cell layer];
    [layer setCornerRadius:5];
    [layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [layer setShouldRasterize:YES];
    [layer setMasksToBounds:YES];
    cell.clipsToBounds =  NO;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"This is Something IndexPath : %@", [indexPath description]);
    
//    NSDictionary *filterDic = [self.filterValuesArray objectAtIndex:indexPath.row];
    
//    NSArray* keysArray=[[self.filterValuesDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray* keysArray=nil;
    
    if (self.isForGrowthForm)
    {
        keysArray=GROWTH_FORM;
    }
    else
    {
        keysArray=FLOWER_COLORS;
    }
    
    NSString* key=[keysArray objectAtIndex:indexPath.row];
    NSMutableDictionary* dictionary=[[self.filterValuesDictionary valueForKey:key] mutableCopy];
    NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
    isSelected=[NSNumber numberWithBool:!isSelected.boolValue];
    [dictionary setValue:isSelected forKey:@"isSelected"];
    [self.filterValuesDictionary setValue:dictionary forKey:key];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"familiesSelected"];
    
    if (self.isForGrowthForm)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.filterValuesDictionary forKey:@"growthFormDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.filterValuesDictionary forKey:@"flowerColorsDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
 
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FAMILY_FILTER_CELL_NOTIFICATION object:nil];
    
    [self.collectionView reloadData];
}




@end
