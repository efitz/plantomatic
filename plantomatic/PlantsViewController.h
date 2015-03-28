//
//  PlantsViewController.h
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface PlantsViewController : GAITrackedViewController<UITableViewDelegate, UITableViewDataSource,UISearchDisplayDelegate, UISearchBarDelegate>

-(void) populatePlants;


@end
