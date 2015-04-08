//
//  ScrollImageViewController.m
//  plantomatic
//
//  Created by developer on 4/2/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "ScrollImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utility.h"

@interface ScrollImageViewController ()
@property (nonatomic, strong) UIImageView *imageView;
- (void)centerScrollViewContents;

@end

@implementation ScrollImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Set a nice title
    self.title = @"Image";
    
    if([Utility isiOS7])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Set up the image we want to scroll & zoom and add it to the scroll view
    //UIImage *image = [UIImage imageNamed:@"Placeholder.png"];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    //self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    [self.scrollView addSubview:self.imageView];
    
    // Tell the scroll view the size of the contents
    self.scrollView.contentSize = CGSizeMake(0, 0);//;image.size;
    
    
    
    __weak ScrollImageViewController* weakSelf=self;
    
    [self.imageView setImageWithURL:self.theURL placeholderImage:[UIImage imageNamed:@"Placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
            weakSelf.scrollView.contentSize = image.size;
            
            // Set up the minimum & maximum zoom scales
            CGRect scrollViewFrame = weakSelf.scrollView.frame;
            CGFloat scaleWidth = scrollViewFrame.size.width / weakSelf.scrollView.contentSize.width;
            CGFloat scaleHeight = scrollViewFrame.size.height / weakSelf.scrollView.contentSize.height;
            CGFloat minScale = MIN(scaleWidth, scaleHeight);
            
            weakSelf.scrollView.minimumZoomScale = minScale;
            weakSelf.scrollView.maximumZoomScale = 1.0f;
            weakSelf.scrollView.zoomScale = minScale;
            [weakSelf centerScrollViewContents];
            
        });
        
        
    }];
    
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
    
    //Google Analytics manual view tracking
    //id tracker = [[GAI sharedInstance] defaultTracker];
    //[tracker set:kGAIScreenName
    //       value:@"High Res Image View"];
    //[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}


@end
