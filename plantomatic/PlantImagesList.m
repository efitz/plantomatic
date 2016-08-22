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
        _nameText               = [Utility getStringValueWithDict:dict key:@"NameText"];
        _imageKindText          = [Utility getStringValueWithDict:dict key:@"ImageKindText"];
        
        //Additional things that previously not parsing
        _imageId                = [Utility getIntValueWithDict:dict key:@"ImageId"];
        _nameId                 = [Utility getIntValueWithDict:dict key:@"NameId"];
        _specimenId             = [Utility getIntValueWithDict:dict key:@"SpecimenId"];
        _specimenText           = [Utility getStringValueWithDict:dict key:@"SpecimenText"];
        _caption                = [Utility getStringValueWithDict:dict key:@"Caption"];
        _longDescription        = [Utility getStringValueWithDict:dict key:@"LongDescription"];
        _barcode                = [Utility getStringValueWithDict:dict key:@"Barcode"];
        _copyright              = [Utility getStringValueWithDict:dict key:@"Copyright"];
        _licenseUrl             = [Utility getStringValueWithDict:dict key:@"LicenseUrl"];
        _licenseName            = [Utility getStringValueWithDict:dict key:@"LicenseName"];
        _photographer           = [Utility getStringValueWithDict:dict key:@"Photographer"];
        _detailUrl              = [Utility getStringValueWithDict:dict key:@"DetailUrl"];
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
