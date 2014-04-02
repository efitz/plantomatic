//
//  ScrollImageViewController.h
//  plantomatic
//
//  Created by developer on 4/2/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollImageViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSURL *theURL;

@end
