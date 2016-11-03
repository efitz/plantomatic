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

@optional
- (void)plantImagesFetchSucceed:(PlantImagesList *)plantImagesList;
@optional
- (void)plantImagesFetchFailed:(NSString *)errorMessage;

//////
//-(void) fetchIntroductionForPlant:(SpeciesFamily*) plant;
@optional
- (void)introductionFetchOperationSucceed:(NSString*)introduction
                          isOnlyWithGenus:(BOOL)isOnlyWithGenus;
@optional
- (void)introductionFetchOperationFail:(NSString *)errorMessage;

//-(void) fetchDescriptionForPlant:(SpeciesFamily*) plant;
@optional
- (void)descriptionFetchOperationSucceed:(NSString*)description
                          isOnlyWithGenus:(BOOL)isOnlyWithGenus;
@optional
- (void)descriptionFetchOperationFail:(NSString *)errorMessage;


////
@optional
- (void)pageUrlOperationSuccess:(NSString *)pageUrl;
@optional
- (void)pageUrlOperationFail:(NSString *)errorMessage;



@end
