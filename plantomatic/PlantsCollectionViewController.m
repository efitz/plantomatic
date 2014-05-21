//
//  PlantsCollectionViewController.h
//  plantomatic
//
//  Created by developer on 4/2/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.

#import "PlantsCollectionViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "PlantCollectionViewCell.h"
#import "CCoverflowTitleView.h"
#import "CCoverflowCollectionViewLayout.h"
#import "CReflectionView.h"
#import "PlantImagesList.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "ScrollImageViewController.h"
#import "Utility.h"

@interface PlantsCollectionViewController ()
@property (readwrite, nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (readwrite, nonatomic, assign) NSInteger cellCount;
@property (readwrite, nonatomic, strong) CCoverflowTitleView *titleView;
@end

@implementation PlantsCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if([Utility isiOS7])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
	self.cellCount = 10;
	[self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CCoverflowTitleView class]) bundle:NULL] forSupplementaryViewOfKind:@"title" withReuseIdentifier:@"title"];
	self.cellCount = self.assets.count;
}

#pragma mark -

- (void)updateTitle
{
    // Asking a collection view for indexPathForItem inside a scrollViewDidScroll: callback seems unreliable.
    //	NSIndexPath *theIndexPath = [self.collectionView indexPathForItemAtPoint:(CGPoint){ CGRectGetMidX(self.collectionView.frame) + self.collectionView.contentOffset.x, CGRectGetMidY(self.collectionView.frame) }];
	NSIndexPath *theIndexPath = ((CCoverflowCollectionViewLayout *)self.collectionView.collectionViewLayout).currentIndexPath;
	if (theIndexPath == NULL)
    {
		self.titleView.titleLabel.text = NULL;
    }
	else
    {
		//NSURL *theURL = [self.assets objectAtIndex:theIndexPath.row];
        PlantImageInfo *plantImageInfo = [self.assets objectAtIndex:theIndexPath.row];
//        NSURL *theURL =[NSURL URLWithString:plantImageInfo.thumbnailUrl];
//		self.titleView.titleLabel.text = [NSString stringWithFormat:@"%@", theURL.lastPathComponent];
        self.titleView.titleLabel.text = [NSString stringWithFormat:@"%@\n%@", plantImageInfo.nameText, plantImageInfo.imageKindText];

    }
}

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
	return(self.cellCount);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	PlantCollectionViewCell *theCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"COLLECTION_VIEW_CELL" forIndexPath:indexPath];
    
	if (theCell.gestureRecognizers.count == 0)
    {
		[theCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)]];
    }
    
	theCell.backgroundColor = [UIColor colorWithHue:(float)indexPath.row / (float)self.cellCount saturation:0.333 brightness:1.0 alpha:1.0];
    
	if (indexPath.row < self.assets.count)
    {
        PlantImageInfo *plantImageInfo = [self.assets objectAtIndex:indexPath.row];
        NSURL *theURL =[NSURL URLWithString:plantImageInfo.thumbnailUrl];
        
        [theCell.imageView setImageWithURL:theURL placeholderImage:[UIImage imageNamed:@"Placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            theCell.reflectionImageView.image=image;
        }];
        
		theCell.backgroundColor = [UIColor clearColor];
    }
    
	return(theCell);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	CCoverflowTitleView *theView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"title" forIndexPath:indexPath];
	self.titleView = theView;
	[self updateTitle];
	return(theView);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self updateTitle];
}

#pragma mark -

- (void)tapCell:(UITapGestureRecognizer *)inGestureRecognizer
{
	NSIndexPath *theIndexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
    
	NSLog(@"%@", [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:theIndexPath]);
    
    PlantImageInfo *plantImageInfo = [self.assets objectAtIndex:theIndexPath.row];
    NSURL *theURL =[NSURL URLWithString:plantImageInfo.detailJpgUrl];
	NSLog(@"%@", theURL);
    
    ScrollImageViewController* scrollImageViewController=[[ScrollImageViewController alloc] initWithNibName:@"ScrollImageViewController" bundle:[NSBundle mainBundle]];
    scrollImageViewController.theURL=theURL;
    [self.navigationController pushViewController:scrollImageViewController animated:YES];
    
}

@end
