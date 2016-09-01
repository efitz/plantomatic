//
//  PlantImageViewController.m
//  plantomatic
//
//  Created by developer on 8/18/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utility.h"

@interface PlantImageViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation PlantImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage* placeHolderImage = [Utility imageWithColor:[UIColor clearColor]];
    
    [self.imgView setImageWithURL:self.theURL placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        //do nothing here
    }];

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

@end
