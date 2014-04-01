//
//  GenericService.m
//  plantomatic
//
//  Created by developer on 4/1/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "GenericService.h"

@interface GenericService()
@property (nonatomic, strong) NSOperationQueue *theOperationQueue;
@end

@implementation GenericService
@synthesize theOperationQueue = _theOperationQueue;


- (NSOperationQueue *)retrieverOperationQueue {
	if(nil == self.theOperationQueue) {
		// lazy creation of the queue for retrieving the earthquake data
		NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        self.theOperationQueue=queue;
        [ self.theOperationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
        self.theOperationQueue.maxConcurrentOperationCount = 1;
	}
	return self.theOperationQueue;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == self.theOperationQueue && [keyPath isEqualToString:@"operations"]) {
        if ([self.theOperationQueue.operations count] == 0) {
            // Do something here when your queue has completed
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}


-(void) dealloc
{
    [self.theOperationQueue removeObserver:self forKeyPath:@"operations" context:NULL];
    [self.theOperationQueue cancelAllOperations];
    
    
}

@end
