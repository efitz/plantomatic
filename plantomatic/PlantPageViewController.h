//
//  PlantPageViewController.h
//  plantomatic
//
//  Created by developer on 8/17/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlantPageViewController;

@protocol PlantPageViewControllerDelegate <NSObject>

/**
 Called when the number of pages is updated.
 
 - parameter tutorialPageViewController: the TutorialPageViewController instance
 - parameter count: the total number of pages.
 */

-(void) plantPageViewController:(PlantPageViewController*)plantPageViewController
             didUpdatePageCount:(int)index;

/**
 Called when the current index is updated.
 
 - parameter tutorialPageViewController: the TutorialPageViewController instance
 - parameter index: the index of the currently visible page.
 */

-(void) plantPageViewController:(PlantPageViewController*)plantPageViewController
             didUpdatePageIndex:(int)index;


@end

@interface PlantPageViewController : UIPageViewController

@property (nonatomic, weak) id<PlantPageViewControllerDelegate> pageControlDelegate;

@property (readwrite, nonatomic, strong) NSArray *assets;

-(void)scrollToViewController:(int)newIndex;

@end


