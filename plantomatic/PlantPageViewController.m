//
//  PlantPageViewController.m
//  plantomatic
//
//  Created by developer on 8/17/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantPageViewController.h"
#import "PlantImagesList.h"
#import "PlantImageViewController.h"

@interface PlantPageViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    NSMutableArray* _orderedViewControllers;
}
@property (strong, nonatomic) NSMutableArray* orderedViewControllers;


@end



@implementation PlantPageViewController


-(UIViewController*)newViewControllerWithImageUrl:(NSURL*)theURL{
 
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlantImageViewController *plantImageViewController = (PlantImageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlantImageViewController"];
    plantImageViewController.theURL = theURL;    
    return plantImageViewController;
}


-(NSMutableArray*)orderedViewControllers{
    
    if (_orderedViewControllers == nil) {
        
        _orderedViewControllers = [[NSMutableArray alloc] init];
        
        for (int i=0; i<self.assets.count; i++)
        {
            PlantImageInfo *plantImageInfo = [self.assets objectAtIndex:i];
            NSURL *theURL =[NSURL URLWithString:plantImageInfo.thumbnailUrl];
            [_orderedViewControllers addObject:[self newViewControllerWithImageUrl:theURL]];
        }
        
    }
    
    return _orderedViewControllers;
}

/**
 Scrolls to the view controller at the given index. Automatically calculates
 the direction.
 
 - parameter newIndex: the new index to scroll to
 */

-(void)scrollToViewController:(int)newIndex {
    
    if (self.viewControllers.firstObject != nil)
    {
        long currentIndex = [self.orderedViewControllers indexOfObject:self.viewControllers.firstObject];
        
        UIPageViewControllerNavigationDirection direction = newIndex >= currentIndex? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
        
        UIViewController* nextViewController = [self.orderedViewControllers objectAtIndex:newIndex];
        
        [self scrollToViewController:nextViewController direction:direction];
    }
}



/**
 Scrolls to the given 'viewController' page.
 
 - parameter viewController: the view controller to show.
 */

-(void)scrollToViewController:(UIViewController*)viewController
                    direction:(UIPageViewControllerNavigationDirection)direction
{
    __typeof(self) __weak welf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setViewControllers:@[viewController] direction:direction animated:true completion:^(BOOL finished) {
            // Setting the view controller programmatically does not fire
            // any delegate methods, so we have to manually notify the
            // 'tutorialDelegate' of the new index.
            [welf notifyTutorialDelegateOfNewIndex];
        }];
    });

    
}


/**
 Notifies '_tutorialDelegate' that the current page index was updated.
 */

-(void)notifyTutorialDelegateOfNewIndex
{
    if (self.viewControllers.firstObject != nil)
    {
        int index =(int) [self.orderedViewControllers indexOfObject:self.viewControllers.firstObject];
        
        [self.pageControlDelegate plantPageViewController:self
                                       didUpdatePageIndex:index];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
    
    UIViewController* viewController = self.orderedViewControllers.firstObject;
    
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:true completion:^(BOOL finished) {}];
    
    [self.pageControlDelegate plantPageViewController:self
                                   didUpdatePageCount:(int)self.orderedViewControllers.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPageViewControllerDataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
     int viewControllerIndex = (int)[self.orderedViewControllers indexOfObject:viewController];
    
    int previousIndex = viewControllerIndex - 1 ;
    
    // User is on the first view controller and swiped left to loop to
    // the last view controller.

    if (previousIndex>=0){
        //ok
    }
    else
        return [self.orderedViewControllers lastObject];
    
    if (self.orderedViewControllers.count > previousIndex) {
        //ok
    }
    else
        return nil;
    
    UIViewController* viewControllerToReturn = self.orderedViewControllers[previousIndex];
    
    
    if ([viewControllerToReturn isKindOfClass:[PlantImageViewController class]]) {
        return  viewControllerToReturn;
    }
    
    return nil;
}


- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int viewControllerIndex = (int)[self.orderedViewControllers indexOfObject:viewController];
    
    int nextIndex = viewControllerIndex + 1 ;
    
    int orderedViewControllersCount = (int) self.orderedViewControllers.count;
    
    // User is on the last view controller and swiped right to loop to
    // the first view controller.

    if (orderedViewControllersCount != nextIndex){
        //ok
    }
    else
        return [self.orderedViewControllers firstObject];
    
    if (orderedViewControllersCount > nextIndex) {
        //ok
    }
    else
        return nil;
    
    
    UIViewController* viewControllerToReturn = self.orderedViewControllers[nextIndex];
    
    
    if ([viewControllerToReturn isKindOfClass:[PlantImageViewController class]]) {
        return  viewControllerToReturn;
    }
    
    return nil;
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self notifyTutorialDelegateOfNewIndex];
}

@end
