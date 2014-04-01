//
//  PlantImagesService.h
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "GenericService.h"

@class PlantImagesList;

@interface PlantImagesService : GenericService

- (id)initServiceWithDelegate:(id)delegate;

- (void)fetchPlantImagesListForGenus:(NSString*)genus
                             species:(NSString*)species;

@end


@protocol PlantImagesServiceDelegate <NSObject>

- (void)plantImagesFetchSucceed:(PlantImagesList *)plantImagesList;
- (void)plantImagesFetchFailed:(NSString *)errorMessage;

@end