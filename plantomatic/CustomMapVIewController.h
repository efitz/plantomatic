//
//  CustomMapVIewController.h
//  MapKitCustomizations
//
//  Created by Abdul Haseeb on 7/28/16.
//  Copyright © 2016 Abdul Haseeb. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HandleMapSearch <NSObject>

- (void)dropPinZoomIn:(MKPlacemark *)placemark
              address:(NSString*)address;
@end

@interface CustomMapVIewController : UIViewController

@end
