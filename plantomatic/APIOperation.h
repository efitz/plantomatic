//
//  APIOperation.h
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIOperation : NSOperation


/*!
 Create an API operation. Use this to pass in a list of params
 to create a request with the body encoded as form data.
 */
- (id)initWithUrl:(NSString *)url method:(NSString *)method params:(NSDictionary *)paramsDict delegate:(id)delegate successAction:(SEL)successSelector andFailAction:(SEL)failSelector;

@end
