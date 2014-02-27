//
//  PlantsViewController.h
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlantsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic,strong) NSMutableArray *plants;

-(void) populatePlants;


@end
