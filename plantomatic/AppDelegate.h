//
//  AppDelegate.h
//  plantomatic
//
//  Created by ehfitz on 2/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversionTestViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (nonatomic,strong) NSString *databaseName;
@property (nonatomic,strong) NSString *databasePath;


-(void) createAndCheckDatabase;

@end
