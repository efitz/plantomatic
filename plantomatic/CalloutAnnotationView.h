//
//  CalloutAnnotationView.h
//  CustomCalloutSample
//
//  Created by tochi on 11/05/17.
//  Copyright 2011 aguuu,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class CalloutAnnotation;
@protocol CalloutAnnotationViewDelegate;
@interface CalloutAnnotationView : MKAnnotationView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *goButton;


@property (nonatomic, assign) id<CalloutAnnotationViewDelegate> delegate;
@end

@protocol CalloutAnnotationViewDelegate
@required
- (void)moreInfoButtonClicked:(CalloutAnnotation*)annotation;
- (void)goButtonClicked:(CalloutAnnotation*)annotation;
@end
