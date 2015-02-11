//
//  SpeciesFamily.h
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeciesFamily : NSObject

@property (nonatomic,assign) int spID;
@property (nonatomic,retain) NSString *family;
@property (nonatomic,strong) NSString *genus;
@property (nonatomic,strong) NSString *species;
@property (nonatomic,strong) NSString *classification;
@property (nonatomic,strong) NSString *habit;
@property (nonatomic,strong) NSString *isImageAvailabe;
@property (nonatomic,strong) NSString *flowerColor;
@property (nonatomic,strong) NSString *commonName;


@end
