//
//  PlantImageInfo.h
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlantImageInfo : NSObject

//ThumbnailUrl
//DetailJpgUrl
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *detailJpgUrl;

//Caption: "Gregg - 1131 - Mexico",
//ImageKindText: "Herbarium Specimen"
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *imageKindText;


-(id) initWithDict:(NSDictionary *)dict;

@end


@interface PlantImagesList : NSObject

@property(nonatomic, strong) NSArray *plantImages;

- (id)initWithArrayOfDictionaries:(NSArray *)arrayOfDic;

@end