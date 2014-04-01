//
//  PlantImagesService.m
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantImagesService.h"
#import "InternetDetector.h"
#import "APIOperation.h"
#import "Constants.h"
#import "Utility.h"
#import "PlantImagesList.h" 


@interface PlantImagesService()

@property (nonatomic, weak) id<PlantImagesServiceDelegate> delegate;

- (void)plantIdFetchOperationSuccess:(NSString *)jsonResponse;
- (void)plantImagesFetchOperationSuccess:(NSString *)jsonResponse;
- (void)plantImagesFetchOperationFail:(NSString *)errorMessage;

@end

@implementation PlantImagesService

@synthesize delegate = _delegate;

- (id)initServiceWithDelegate:(id)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
    }
    
    return self;
}

- (void)fetchPlantImagesListForGenus:(NSString*)genus
                             species:(NSString*)species
{
    if ([InternetDetector isNetAvailable])
    {
        // //[Genus+Species]
        NSString *url = [NSString stringWithFormat:URL_TO_FETCH_PLANT_ID, genus, species];
        APIOperation *operation = [[APIOperation alloc] initWithUrl:url method:HTTP_REQUEST_METHOD_GET params:nil delegate:self successAction:@selector(plantIdFetchOperationSuccess:) andFailAction:@selector(plantImagesFetchOperationFail:)];
        [[self retrieverOperationQueue] addOperation:operation];
    }
    else
    {
        [self plantImagesFetchOperationFail:NO_INTERNET_MSG];
    }

    
}


- (void)plantIdFetchOperationSuccess:(NSString *)jsonResponse
{
    //here we want to get NameId from json
    //then we will use that NameId to get images attributes array
    //1. ThumbnailUrl
    //2. DetailJpgUrl
    
    if ([InternetDetector isNetAvailable])
    {
        NSData *data = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSArray* array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *dict = [array objectAtIndex:0u];
        
        if (dict != nil)
        {
            int plantId=[Utility getIntValueWithDict:dict key:NAME_ID_KEY];
            
            //[plantId]
            NSString *url = [NSString stringWithFormat:URL_TO_FETCH_IMAGES_LIST_FOR_PLANT_ID, plantId];
            APIOperation *operation = [[APIOperation alloc] initWithUrl:url method:HTTP_REQUEST_METHOD_GET params:nil delegate:self successAction:@selector(plantImagesFetchOperationSuccess:) andFailAction:@selector(plantImagesFetchOperationFail:)];
            [[self retrieverOperationQueue] addOperation:operation];
            
        }
        else
        {
            [self plantImagesFetchOperationFail:@"API response has no data"];
        }
    }
    else
    {
        [self plantImagesFetchOperationFail:NO_INTERNET_MSG];
    }
    
}


- (void)plantImagesFetchOperationSuccess:(NSString *)jsonResponse
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(plantImagesFetchSucceed:)])
    {
        NSData *data = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSArray* array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        PlantImagesList *plantImagesList = [[PlantImagesList alloc] initWithArrayOfDictionaries:array];
        [self.delegate plantImagesFetchSucceed:plantImagesList];
    }

    
}


- (void)plantImagesFetchOperationFail:(NSString *)errorMessage;
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(plantImagesFetchFailed:)])
    {
        [self.delegate plantImagesFetchFailed:errorMessage];
    }
}




@end
