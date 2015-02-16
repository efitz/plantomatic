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


/*
 http://services.tropicos.org/Name/Search?name=poa+annua&type=scientificname&apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json
 
 http://services.tropicos.org/Name/25509881/Images?apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json
 */

#define API_BASE_URL @"http://services.tropicos.org"

 //[Genus+Species]
#define URL_TO_FETCH_PLANT_ID [NSString stringWithFormat:@"%@/Name/Search?name=%%@+%%@&type=scientificname&apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json", API_BASE_URL]

//[plantId]
#define URL_TO_FETCH_IMAGES_LIST_FOR_PLANT_ID [NSString stringWithFormat:@"%@/Name/%%d/Images?apikey=2e8b6fdc-3a67-401d-8564-793700526367&format=json", API_BASE_URL]

#define REFRESH_NOTIFICATION @"REFRESH_NOTIFICATION"

#define REFRESH_FAMILY_FILTER_CELL_NOTIFICATION @"REFRESH_FAMILY_FILTER_CELL_NOTIFICATION"


