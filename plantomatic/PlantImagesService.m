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
#import "SpeciesFamily.h"


@interface PlantImagesService()

@property (nonatomic, weak) id<PlantImagesServiceDelegate> delegate;

- (void)plantIdFetchOperationSuccess:(NSString *)jsonResponse;
- (void)plantImagesFetchOperationSuccess:(NSString *)jsonResponse;
- (void)plantImagesFetchOperationFail:(NSString *)errorMessage;


@property (nonatomic, strong) SpeciesFamily* plantForIntro;
@property (nonatomic, strong) SpeciesFamily* plantForDescription;


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

////////////////////////////////////////
// Utility method

-(NSString*) getPlantIntroductionFromResponseString:(NSString*)jsonResponse {
    
    NSData *data = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    NSString* plantIntroduction = nil;
    
    if (dict != nil)
    {
        NSDictionary *queryDict = [Utility getDictionaryValueWithDict:dict key:@"query"];
        
        if (queryDict!=nil) {
            NSDictionary *pagesDict = [Utility getDictionaryValueWithDict:queryDict key:@"pages"];
            
            if (pagesDict!=nil) {
                NSArray* keysArray = [pagesDict allKeys];
                
                NSString* pageIdKey = [keysArray objectAtIndex:0U];
                
                if (![pageIdKey isEqualToString:@"-1"]) {
                    //We have found the Intro
                    NSDictionary *introPageDict = [Utility getDictionaryValueWithDict:pagesDict key:pageIdKey];
                    
                    if (introPageDict!=nil) {
                        plantIntroduction = [Utility getStringValueWithDict:introPageDict key:@"extract"];
                        if (plantIntroduction.length == 0) {
                            plantIntroduction = nil;
                        }
                    }
                    
                }
            }
        }
    }

    return plantIntroduction;
}



-(NSString*) getPlantDescriptionFromResponseString:(NSString*)jsonResponse {
    
    NSData *data = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSString* plantDesription = nil;
    
    if (dict != nil)
    {
        NSDictionary *queryDict = [Utility getDictionaryValueWithDict:dict key:@"query"];
        
        if (queryDict!=nil) {
            NSDictionary *pagesDict = [Utility getDictionaryValueWithDict:queryDict key:@"pages"];
            
            if (pagesDict!=nil) {
                NSArray* keysArray = [pagesDict allKeys];
                
                NSString* pageIdKey = [keysArray objectAtIndex:0U];
                
                if (![pageIdKey isEqualToString:@"-1"]) {
                    
                    NSDictionary *desciptionPageDict = [Utility getDictionaryValueWithDict:pagesDict key:pageIdKey];
                    
                    if (desciptionPageDict!=nil) {
                        plantDesription = [Utility getStringValueWithDict:desciptionPageDict key:@"extract"];
                        
                        
                        ////////////////////////////
                        /// Only get description part here from plain text
                        
                        NSString *searchKeyword = @"== Description ==";
                        
                        NSRange rangeOfYourString = [plantDesription rangeOfString:searchKeyword];
                        
                        if(rangeOfYourString.location == NSNotFound)
                        {
                            // error condition — the text searchKeyword wasn't in 'string'
                            plantDesription = nil;
                        }
                        else{
                            NSLog(@"range position %lu", rangeOfYourString.location);
                            
                            NSString *subString = [plantDesription substringToIndex:rangeOfYourString.location];
                            plantDesription = [plantDesription stringByReplacingOccurrencesOfString:subString withString:@""];
                            plantDesription = [plantDesription stringByReplacingOccurrencesOfString:searchKeyword withString:@""];

                            
                            rangeOfYourString = [plantDesription rangeOfString:@"=="];
                            
                            if(rangeOfYourString.location == NSNotFound)
                            {
                                // means no other section and our description is complete
                            }
                            else
                            {
                                plantDesription = [plantDesription substringToIndex:rangeOfYourString.location];
                            }
                            
                            plantDesription = [plantDesription stringByTrimmingCharactersInSet:
                                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                            NSLog(@"-----------%@----",plantDesription);
                        }
                        
                        
                        
                        //////////////////////////////
                        
                        if (plantDesription.length == 0) {
                            plantDesription = nil;
                        }
                    }

                    
                    /*
                    //We have found the Intro
                    NSDictionary *desciptionPageDict = [Utility getDictionaryValueWithDict:pagesDict key:pageIdKey];
                    
                    if (desciptionPageDict!=nil) {
                        NSArray*  revisionsArray = [Utility getArrayValueWithDict:desciptionPageDict key:@"revisions"];
                        
                        
                        NSDictionary* revisionDic = [revisionsArray objectAtIndex:0U];

                        
                        if (revisionDic!=nil) {
                            
                            plantDesription = [Utility getStringValueWithDict:revisionDic key:@"*"];

                            if (plantDesription.length == 0) {
                                plantDesription = nil;
                            }
                        }
                        
                    }
                    */
                    
                }
            }
        }
    }
    
    return plantDesription;
}





/////////////////////////////////////////////

-(void) fetchIntroductionForPlant:(SpeciesFamily*) plant
{
    self.plantForIntro = plant;
    
    if ([InternetDetector isNetAvailable])
    {
        // //[Genus+Species]
        NSString *url = [NSString stringWithFormat:URL_TO_FETCH_PLANT_INTRO_USING_GENUS_SPECIES_URL, plant.genus, plant.species];
        APIOperation *operation = [[APIOperation alloc] initWithUrl:url method:HTTP_REQUEST_METHOD_GET params:nil delegate:self successAction:@selector(introductionFetchOperationSuccess:) andFailAction:@selector(introductionFetchOperationFail:)];
        [[self retrieverOperationQueue] addOperation:operation];
    }
    else
    {
        [self introductionFetchOperationFail:NO_INTERNET_MSG];
    }

}

- (void)introductionFetchOperationSuccess:(NSString *)jsonResponse
{
    
    NSString* plantIntroduction = [self getPlantIntroductionFromResponseString:jsonResponse];

    if (plantIntroduction!=nil)
    {
        [self.delegate introductionFetchOperationSucceed:plantIntroduction
                                         isOnlyWithGenus:false];
    }
    else
    {
        //Intro not found, try with genus for Intro
        
        if ([InternetDetector isNetAvailable])
        {
            //[Genus]
            NSString *url = [NSString stringWithFormat:URL_TO_FETCH_PLANT_INTRO_USING_GENUS_URL, self.plantForIntro.genus];
            APIOperation *operation = [[APIOperation alloc] initWithUrl:url method:HTTP_REQUEST_METHOD_GET params:nil delegate:self successAction:@selector(introductionUsingGenusFetchOperationSuccess:) andFailAction:@selector(introductionFetchOperationFail:)];
            [[self retrieverOperationQueue] addOperation:operation];
        }
        else
        {
            [self introductionFetchOperationFail:NO_INTERNET_MSG];
        }

    }
}



- (void)introductionUsingGenusFetchOperationSuccess:(NSString *)jsonResponse
{
    
    NSString* plantIntroduction = [self getPlantIntroductionFromResponseString:jsonResponse];
    
    if (plantIntroduction!=nil)
    {
        [self.delegate introductionFetchOperationSucceed:plantIntroduction
                                         isOnlyWithGenus:true];
    }
    else
    {
        [self introductionFetchOperationFail:NO_INTRODUCTION_FOUND_MSG];
    }
}


- (void)introductionFetchOperationFail:(NSString *)errorMessage;
{
    self.plantForIntro = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(introductionFetchOperationFail:)])
    {
        [self.delegate introductionFetchOperationFail:errorMessage];
    }
}

///////////////////////////////////////////

-(void) fetchDescriptionForPlant:(SpeciesFamily*) plant
{
    self.plantForDescription = plant;
    
    if ([InternetDetector isNetAvailable])
    {
        // //[Genus+Species]
        NSString *url = [NSString stringWithFormat:URL_TO_FETCH_PLANT_DESC_USING_GENUS_SPECIES_URL, plant.genus, plant.species];
        APIOperation *operation = [[APIOperation alloc] initWithUrl:url method:HTTP_REQUEST_METHOD_GET params:nil delegate:self successAction:@selector(descriptionFetchOperationSuccess:) andFailAction:@selector(descriptionFetchOperationFail:)];
        [[self retrieverOperationQueue] addOperation:operation];
    }
    else
    {
        [self descriptionFetchOperationFail:NO_INTERNET_MSG];
    }
    

}


- (void)descriptionFetchOperationSuccess:(NSString *)jsonResponse
{
    
    NSString* plantDescription = [self getPlantDescriptionFromResponseString:jsonResponse];
    
    if (plantDescription!=nil)
    {
        [self.delegate descriptionFetchOperationSucceed:plantDescription
                                        isOnlyWithGenus:false];
    }
    else
    {
        //Intro not found, try with genus for Intro
        
        if ([InternetDetector isNetAvailable])
        {
            //[Genus]
            NSString *url = [NSString stringWithFormat:URL_TO_FETCH_PLANT_DESC_USING_GENUS_URL, self.plantForDescription.genus];
            APIOperation *operation = [[APIOperation alloc] initWithUrl:url method:HTTP_REQUEST_METHOD_GET params:nil delegate:self successAction:@selector(descriptionUsingGenusFetchOperationSuccess:) andFailAction:@selector(descriptionFetchOperationFail:)];
            [[self retrieverOperationQueue] addOperation:operation];
        }
        else
        {
            [self descriptionFetchOperationFail:NO_INTERNET_MSG];
        }
        
    }
}

- (void)descriptionUsingGenusFetchOperationSuccess:(NSString *)jsonResponse
{
    
    NSString* plantDescription = [self getPlantDescriptionFromResponseString:jsonResponse];
    
    if (plantDescription!=nil)
    {
        [self.delegate descriptionFetchOperationSucceed:plantDescription
                                         isOnlyWithGenus:true];
    }
    else
    {
        [self descriptionFetchOperationFail:NO_DESCRIPTION_FOUND_MSG];
    }
}




- (void)descriptionFetchOperationFail:(NSString *)errorMessage;
{
    self.plantForDescription = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(descriptionFetchOperationFail:)])
    {
        [self.delegate descriptionFetchOperationFail:errorMessage];
    }
}


@end
