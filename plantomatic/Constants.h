//
//  constants.h
//  plantomatic
//
//  Created by ehfitz on 2/26/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


enum FilterByValue {
    FilterByValueFamily,
    FilterByValueGenus,
    FilterByValueClassification,
    FilterByValueHabit
};

typedef enum
{
    FilterTypeCommonName,
    FilterTypeImage
    
}FilterType;


#define MIXPANEL_TOKEN @"9d75c96819572a4c6a34fc2b016f8ba6"

#define GOOGLE_ANALYTICS_TRACKER_ID @"UA-56120368-1"


#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define REQUEST_TIMEOUT_MSG @"Request timeout, please try again later."

//Request Header
#define HTTP_HEADER_CONTENT_TYPE_FORM_URL_ENCODED   @"application/x-www-form-urlencoded"
#define HTTP_HEADER_CONTENT_TYPE_JSON               @"application/json"

//Key Constants
#define KEY_CONTENT_TYPE    @"Content-Type"

#define KEY_ACCEPT_TYPE               @"Accept"
#define KEY_ACCEPT_TYPE_JSON         @"application/json"


//Http Request Method Types
#define HTTP_REQUEST_METHOD_GET     @"GET"
#define HTTP_REQUEST_METHOD_POST    @"POST"


#define KEY_FORMAT @"format"
#define KEY_FORMAT_VALUE_JSON @"json"
#define API_KEY @"apikey"
#define API_KEY_VALUE @"2e8b6fdc-3a67-401d-8564-793700526367"

#define NO_INTERNET_MSG @"You are not connected to the internet. Please connect and retry."
#define NAME_ID_KEY @"NameId"


#define NO_INTRODUCTION_FOUND_MSG @"Introduction not available."
#define NO_DESCRIPTION_FOUND_MSG @"Description not available."


/*
 http://services.tropicos.org/Name/Search?name=poa+annua&type=scientificname&apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json
 
 http://services.tropicos.org/Name/25509881/Images?apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json
 */

#define API_BASE_URL @"http://services.tropicos.org"

 //[Genus+Species]
#define URL_TO_FETCH_PLANT_ID [NSString stringWithFormat:@"%@/Name/Search?name=%%@+%%@&type=scientificname&apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json", API_BASE_URL]

//[plantId]
#define URL_TO_FETCH_IMAGES_LIST_FOR_PLANT_ID [NSString stringWithFormat:@"%@/Name/%%d/Images?apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json", API_BASE_URL]


/////////////////////////////////////////////

//Request: https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=Acer_saccharinum&exsectionformat=plain

//[Genus+Species]
#define URL_TO_FETCH_PLANT_INTRO_USING_GENUS_SPECIES_URL @"https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=%@_%@&exsectionformat=plain"


//[Genus+Species]
#define URL_TO_FETCH_PLANT_INTRO_USING_GENUS_URL @"https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=%@&exsectionformat=plain"

// https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&rvsection=1&titles=Acer_saccharinum&format=json

#define URL_TO_FETCH_PLANT_DESC_USING_GENUS_SPECIES_URL @"https://en.wikipedia.org/w/api.php?action=query&prop=revisions&titles=%@_%@&format=json&prop=extracts&exlimit=1&explaintext"

#define URL_TO_FETCH_PLANT_DESC_USING_GENUS_URL @"https://en.wikipedia.org/w/api.php?action=query&prop=revisions&titles=%@&format=json&prop=extracts&exlimit=1&explaintext"




///////////////////////////////////////////






#define REFRESH_NOTIFICATION @"REFRESH_NOTIFICATION"

#define REFRESH_FAMILY_FILTER_CELL_NOTIFICATION @"REFRESH_FAMILY_FILTER_CELL_NOTIFICATION"










#define FLOWER_COLORS @[@"Red",@"Pink",@"Violet", @"Purple", @"Blue",@"Green",@"Yellow",@"Orange",@"Brown",@"Gray",@"Black",@"White", @"Unknown-Flower"]


#define GROWTH_FORM @[@"Aquatic",@"Bryophyte", @"Cactus", @"Epiphyte", @"Fern", @"Grass", @"Herb", @"Parasite", @"Shrub", @"Tree",@"Vine", @"Unknown"]


#define SORT_COLUMNS @[@"Family",@"Genus", @"Habit", @"Flower_Color", @"Common_Name"]
