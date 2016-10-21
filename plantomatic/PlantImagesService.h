//
//  PlantImagesService.h
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "GenericService.h"

@class PlantImagesList;
@class SpeciesFamily;

@interface PlantImagesService : GenericService

- (id)initServiceWithDelegate:(id)delegate;

- (void)fetchPlantImagesListForGenus:(NSString*)genus
                             species:(NSString*)species;

//


-(void) fetchIntroductionForPlant:(SpeciesFamily*) plant;

-(void) fetchDescriptionForPlant:(SpeciesFamily*) plant;


@end


@protocol PlantImagesServiceDelegate <NSObject>

- (void)plantImagesFetchSucceed:(PlantImagesList *)plantImagesList;
- (void)plantImagesFetchFailed:(NSString *)errorMessage;

//////
//-(void) fetchIntroductionForPlant:(SpeciesFamily*) plant;
- (void)introductionFetchOperationSucceed:(NSString*)introduction
                          isOnlyWithGenus:(BOOL)isOnlyWithGenus;

- (void)introductionFetchOperationFail:(NSString *)errorMessage;

//-(void) fetchDescriptionForPlant:(SpeciesFamily*) plant;
- (void)descriptionFetchOperationSucceed:(NSString*)description
                          isOnlyWithGenus:(BOOL)isOnlyWithGenus;

- (void)descriptionFetchOperationFail:(NSString *)errorMessage;


////
- (void)pageUrlOperationSuccess:(NSString *)pageUrl;
- (void)pageUrlOperationFail:(NSString *)errorMessage;



@end