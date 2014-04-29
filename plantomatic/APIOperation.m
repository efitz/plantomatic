//
//  APIOperation.m
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "APIOperation.h"
#import "Utility.h"
#import "Constants.h"

@interface APIOperation()

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSDictionary *paramsDict;
@property (nonatomic, getter = isJsonBody) BOOL jsonBody;
@property (nonatomic, weak) id delegate;
@property (assign) SEL successSelector;
@property (assign) SEL failSelector;

/*!
 Create NSURLRequest with all the required information
 to make an API call. Currently it only accepts two types
 of body, json and form.
 */
- (NSURLRequest *)createUrlRequest;

/*!
 Checks if a list of attributes or if a json string were passed in and creates
 the appropriate httpBody
 */
- (NSData *)createHTTPBody;

/*!
 Check for errors from API's response and errors.
 
 @return Error message is there is an error. Otherwise nil.
 */
- (NSString *)checkErrorFromResponse:(NSHTTPURLResponse *)response orError:(NSError *)error;

/*!
 Checks if response has status: success
 */
- (BOOL)isResponseSuccessfulForJsonData:(NSData*)responseData;
- (NSString *)errorMessageForJsonData:(NSData*)responseData;
- (void)callDelegate:(id)delegate withAction:(SEL)selector andObject:(id)object;

@end


@implementation APIOperation

- (id)initWithUrl:(NSString *)url method:(NSString *)method params:(NSDictionary *)paramsDict delegate:(id)delegate successAction:(SEL)successSelector andFailAction:(SEL)failSelector
{
    if (self = [super init])
    {
        _url = url;
        _method = method;
        _paramsDict = paramsDict;
        _delegate = delegate;
        _successSelector = successSelector;
        _failSelector = failSelector;
    }
    
    return self;
}


-(void)main
{
	NSURLRequest *urlRequest = [self createUrlRequest];
    
    NSLog(@"%@",urlRequest);
    
    
    // Check if the operation is cancelled
    if (self.isCancelled)
    {
        return;
    }
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    // Check if the operation is cancelled again. Following the old code but I want to remove this.
    if (self.isCancelled)
    {
        return;
    }
    
    NSString *errorMessage = [self checkErrorFromResponse:response orError:error];
    if ([errorMessage length])
    {
        [self callDelegate:self.delegate withAction:self.failSelector andObject:errorMessage];
    }
    else
    {
        NSString *jsonResponse = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        DLog(@"Response :%@",jsonResponse);
        if ([self isResponseSuccessfulForJsonData:data])
        {
            [self callDelegate:self.delegate withAction:self.successSelector andObject:jsonResponse];
        }
        else
        {
            [self callDelegate:self.delegate withAction:self.failSelector andObject:[self errorMessageForJsonData:data]];
        }
    }
}

- (NSURLRequest *)createUrlRequest
{
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    /*
     //here we can set up headers if required
    */
    
    return [urlRequest copy];
}

- (NSData *)createHTTPBody
{
    NSData *httpBody = nil;
    
    // Create a string of params in the format of key=value&
    if ([self.paramsDict count])
    {
        NSMutableData* params = [NSMutableData data];
        for (NSString *key in [self paramsDict])
        {
            NSObject *curValue = [[self paramsDict] valueForKey:key];
            // Check if value is an array. If so create a string of values with the same key.
            if ([curValue isKindOfClass:[NSArray class]])
            {
                NSArray *array = (NSArray *)curValue;
                for (NSString *string in array)
                {
                    NSString *encodedValue = [Utility urlEncodeValue:string usingEncoding:NSUTF8StringEncoding];
                    NSString *keyValueParam = [NSString stringWithFormat:@"%@=%@&", key, encodedValue];
                    [params appendData:[keyValueParam dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            // Create a single key=value& parameter
            else
            {
                NSString *encodedValue = [Utility urlEncodeValue:[[self paramsDict] valueForKey:key] usingEncoding:NSUTF8StringEncoding];
                NSString *keyValueParam = [NSString stringWithFormat:@"%@=%@&", key, encodedValue];
                [params appendData:[keyValueParam dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        
        httpBody = [params copy];
    }
    // Converts the body into data
    else if ([self.body length])
    {
        httpBody = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return httpBody;
}

- (NSString *)checkErrorFromResponse:(NSHTTPURLResponse *)response orError:(NSError *)error
{
    NSString *errorMessage = nil;

    // Check if there is a bad status code that we know how to handle
    switch ([response statusCode])
    {
        case 400:
            errorMessage = @"API Bad Request";
            break;

        case 404:
            errorMessage = @"API Not Found";
            break;
        case kCFURLErrorCannotFindHost:
            errorMessage = @"Server is unavailable.";
            break;
    }
    
    if (errorMessage == nil || error)
    {
        if ([error code] == kCFURLErrorTimedOut)
        {
            errorMessage = REQUEST_TIMEOUT_MSG;
        }
        else
        {
            errorMessage = [error localizedDescription];
        }
    }
    
    return errorMessage;
}

- (BOOL)isResponseSuccessfulForJsonData:(NSData*)responseData
{
    BOOL isSuccessful = NO;
    
    
    //parse out the json data
    NSError* error;
    NSArray* array = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];

    NSDictionary* dict=[array objectAtIndex:0u];
    
    /*
     [{"Error":"No names were found"}]
     */
    
    if (dict != nil)
    {
        NSString *error = [Utility getStringValueWithDict:dict key:@"Error"];
        isSuccessful =error==nil||[error isEqualToString:@""]?YES:NO;
    }
    
    return isSuccessful;
}

- (NSString *)errorMessageForJsonData:(NSData*)responseData
{
    NSString *errorMessage;
    
    
    //parse out the json data
    NSError* error;
    NSArray* array = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
     NSDictionary* dict=[array objectAtIndex:0u];
    
    if (dict != nil)
    {
        errorMessage = [Utility getStringValueWithDict:dict key:@"Error"];
    }
    else
    {
        errorMessage = @"Server is unavailable.";//old-value =>@"We are unable to read the server's response.";
    }
    
    return errorMessage;
}

- (void)callDelegate:(id)delegate withAction:(SEL)selector andObject:(id)object
{
	if (delegate != nil && selector != nil && [delegate respondsToSelector:selector])
	{
        [delegate performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
	}
}

static const int API_TIME_OUT_INTERVAL = 30;

@end
