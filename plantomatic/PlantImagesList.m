//
//  PlantImageInfo.m
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantImagesList.h"
#import "Utility.h"

@implementation PlantImageInfo

-(id) initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self && dict)
    {
        _thumbnailUrl           = [Utility getStringValueWithDict:dict key:@"ThumbnailUrl"];
        _detailJpgUrl           = [Utility getStringValueWithDict:dict key:@"DetailJpgUrl"];
        
        //Caption: "Gregg - 1131 - Mexico",
        //ImageKindText: "Herbarium Specimen"
        _nameText                = [Utility getStringValueWithDict:dict key:@"NameText"];
        _imageKindText          = [Utility getStringValueWithDict:dict key:@"ImageKindText"];
        
    }
    
    return self;
}

@end


@implementation PlantImagesList

- (id)initWithArrayOfDictionaries:(NSArray *)arrayOfDic
{
    self = [super init];
    if (self)
    {
        _plantImages = [self getImagesArrayWitArrayOfDic:arrayOfDic];
    }
    return self;
}

- (NSArray *) getImagesArrayWitArrayOfDic:(NSArray *)imagesArrayOfDic
{
    NSMutableArray *arrayOfImagesInfo = [NSMutableArray array];

    if (imagesArrayOfDic != nil)
    {
        for (int i = 0; i < imagesArrayOfDic.count; i++)
        {
            PlantImageInfo *plantImageInfo = [[PlantImageInfo alloc] initWithDict:[imagesArrayOfDic objectAtIndex:i]];
            [arrayOfImagesInfo addObject:plantImageInfo];
        }
    }
    return [arrayOfImagesInfo copy];
}


@end
