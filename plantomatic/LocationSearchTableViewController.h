//
//  LocationSearchTable1.h
//  plantomatic
//
//  Created by developer on 8/9/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomMapVIewController.h"


@interface LocationSearchTableViewController : UITableViewController<UISearchResultsUpdating>

@property (nonatomic, weak) id<HandleMapSearch> handleMapSearchDelegate;
@property (strong, nonatomic) NSArray* matchingItems;
@property (strong, nonatomic) MKMapView* mapView;

@end
