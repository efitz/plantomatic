//
//  PlantDetailsViewController.h
//  plantomatic
//
//  Created by developer on 8/17/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpeciesFamily;

@interface PlantDetailsViewController : UIViewController

@property (strong, nonatomic) SpeciesFamily *plant;
@property (readwrite, nonatomic, strong) NSArray *assets;

@end
