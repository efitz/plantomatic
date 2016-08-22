//
//  PlantImageInfo.h
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlantImageInfo : NSObject

/*
 {
	"ImageId": 34659,
	"NameId": 22500331,
	"SpecimenId": 1797001,
	"SpecimenText": "Fendler, August - 739",
	"Caption": "Fendler - 739 - United States",
	"LongDescription": "type 1746248",
	"Barcode": "MO-216345",
	"Copyright": "MBG",
	"LicenseUrl": "http:\/\/creativecommons.org\/licenses\/by-nc-sa\/3.0\/",
	"LicenseName": "Attribution Non-Commercial Share Alike",
	"Photographer": "MBG",
	"DetailUrl": "http:\/\/www.tropicos.org\/Image\/34659",
 
 "NameText": "Abronia fragrans Nutt. ex Hook.",
	"ImageKindText": "Herbarium Specimen",
 "ThumbnailUrl": "http:\/\/images.mobot.org\/tropicosthumbnails\/Tropicos\/225\/MO-216345.jpg",
 "DetailJpgUrl": "http:\/\/images.mobot.org\/tropicosimages3\/detailimages\/Tropicos\/225\/E3B8B0DE-4520-43BF-9787-4673EA74093C.jpg"
 }
 */

//ThumbnailUrl
//DetailJpgUrl
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *detailJpgUrl;

//NameText: "Waltheria indica L."
//ImageKindText: "Herbarium Specimen"
@property (nonatomic, strong) NSString *nameText;
@property (nonatomic, strong) NSString *imageKindText;

@property (nonatomic, readwrite) long imageId;
@property (nonatomic, readwrite) long nameId;
@property (nonatomic, readwrite) long specimenId;
@property (nonatomic, strong) NSString *specimenText;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSString *copyright;
@property (nonatomic, strong) NSString *licenseUrl;
@property (nonatomic, strong) NSString *licenseName;
@property (nonatomic, strong) NSString *photographer;
@property (nonatomic, strong) NSString *detailUrl;


-(id) initWithDict:(NSDictionary *)dict;

@end


@interface PlantImagesList : NSObject

@property(nonatomic, strong) NSArray *plantImages;

- (id)initWithArrayOfDictionaries:(NSArray *)arrayOfDic;

@end