
//
//  CustomMapVIewController.m
//  MapKitCustomizations
//
//  Created by Abdul Haseeb on 7/28/16.
//  Copyright © 2016 Abdul Haseeb. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "CustomMapVIewController.h"
#import "Constants.h"
#import "PlantomaticAnnotation.h"
#import "CustomCalloutView.h"
#import "LocationSearchTableViewController.h"
#import "Utility.h"

@interface CustomMapVIewController()<UIGestureRecognizerDelegate,MKMapViewDelegate,HandleMapSearch>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *point;
@property (strong, nonatomic) MKPointAnnotation *searchPoint;
@property (strong, nonatomic) UISearchController *resultSearchController;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@property (readwrite, nonatomic) BOOL isFirstTime;

@end

@implementation CustomMapVIewController

- (void)viewDidLoad
{
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.mapView addGestureRecognizer:lpgr];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestWhenInUseAuthorization];
    self.point = [[MKPointAnnotation alloc] init];
    self.searchPoint = [[MKPointAnnotation alloc] init];
    self.searchPoint.title = @"";
    
    
    self.closeButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.closeButton.layer.borderWidth = 2.0;
    self.closeButton.layer.cornerRadius  = 20.0;

    self.isFirstTime = true;
    ///////////////////////////////////////////////////////////////////
    //// This part brings back to user to last time selected location
    ///////////////////////////////////////////////////////////////////

    if ([Utility isUserHaveSelectedAnyLocation]==true)
    {
        CLLocation* currentLocation = [Utility getCurrentLocation];

        [self getPlacemarkFromLocation:currentLocation];
        
        [self.point setCoordinate:currentLocation.coordinate];
        self.point.title = [NSString stringWithFormat:@"latitude:%.02f longitude:%.02f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
        
        
        float distance =[self.mapView.userLocation.location distanceFromLocation:[[CLLocation alloc]initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude]];
        
        
        if ( distance >= 1000 )  {
            //use km unit
            self.point.subtitle= [NSString stringWithFormat:@"%.02f km",distance/1000];
        }
        else {
            //use m
            self.point.subtitle= [NSString stringWithFormat:@"%.0f meter",distance];
        }
        
        [self.mapView addAnnotation:self.point];
        [self.mapView selectAnnotation:self.point animated:YES];
    }
    ///////////////////////////////////////////////////////////////////

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAddressNotification:) name:@"MBDidReceiveAddressNotification" object:nil];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationSearchTableViewController *locationSearchTable = [storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTable"];

    self.resultSearchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTable];
    self.resultSearchController.searchResultsUpdater = locationSearchTable;
    
    UISearchBar* searchBar = self.resultSearchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Search for places";
    self.navigationItem.titleView = self.resultSearchController.searchBar;
    self.resultSearchController.hidesNavigationBarDuringPresentation = false;
    self.resultSearchController.dimsBackgroundDuringPresentation = true;

    self.definesPresentationContext = true;
    locationSearchTable.mapView = self.mapView;
    locationSearchTable.handleMapSearchDelegate = self;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        [self getPlacemarkFromLocation:[[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude]];
        
        [self.point setCoordinate:touchMapCoordinate];
        self.point.title = [NSString stringWithFormat:@"latitude:%.02f longitude:%.02f",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
        
        
        float distance =[self.mapView.userLocation.location distanceFromLocation:[[CLLocation alloc]initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude]];
        
                       
        if ( distance >= 1000 )  {
            //use km unit
            self.point.subtitle= [NSString stringWithFormat:@"%.02f km",distance/1000];
        }
        else {
            //use m
            self.point.subtitle= [NSString stringWithFormat:@"%.0f meter",distance];
        }
        
        [self.mapView addAnnotation:self.point];
        [self.mapView selectAnnotation:self.point animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (mapView.annotations.count == 1)
    {
        //Area for only one location i.e current gps location
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
    else
    {
        //Area that contains all the locations
        MKMapPoint annotationPoint = MKMapPointForCoordinate(mapView.userLocation.coordinate);
        MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        for (id <MKAnnotation> annotation in mapView.annotations)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        
        double inset = -zoomRect.size.width * 1.0;
        zoomRect = MKMapRectInset(zoomRect, inset, inset);
        [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
        
        [mapView setVisibleMapRect:zoomRect animated:YES];
    }
    
    //The below code is only runs once in case of user have selected any location
    //to calculate the distance of user selected location from gps current location
    if (self.isFirstTime==true && [Utility isUserHaveSelectedAnyLocation]==true) {
        self.isFirstTime = false;
        
        CLLocation* currentLocation = [Utility getCurrentLocation];

        float distance =[self.mapView.userLocation.location distanceFromLocation:[[CLLocation alloc]initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude]];
        
        
        if ( distance >= 1000 )  {
            //use km unit
            self.point.subtitle= [NSString stringWithFormat:@"%.02f km",distance/1000];
        }
        else {
            //use m
            self.point.subtitle= [NSString stringWithFormat:@"%.0f meter",distance];
        }

    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == self.mapView.userLocation)
        return nil;

    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"pin"];
    
    if (pin == nil)
    {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"pin"] ;
    }
    else
        pin.annotation = annotation;
    
    
    NSString *titlename=@"searchingPoint";
    if ([annotation.title isEqualToString:titlename]) {
        pin.pinColor =  MKPinAnnotationColorPurple;
    }
    else{
        pin.pinColor = MKPinAnnotationColorRed;
    }
    
    pin.userInteractionEnabled = YES;

    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.rightCalloutAccessoryView = disclosureButton;
    
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"car"] forState:(UIControlStateNormal)];
    pin.leftCalloutAccessoryView = button;

    
    
    pin.pinColor = MKPinAnnotationColorRed;
    pin.animatesDrop = YES;
    [pin setEnabled:YES];
    [pin setCanShowCallout:YES];

    return pin;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
//    [mapView deselectAnnotation:view.annotation animated:YES];

    if (view.annotation == mapView.userLocation)
    {
        return;
    }
    
//    PlantomaticAnnotation* plantomaticAnnotation = view.annotation;
//    
//    NSArray * arr =[[NSBundle mainBundle] loadNibNamed:@"CustomCalloutView" owner:nil options:nil];
//    CustomCalloutView * calloutView = (CustomCalloutView *) [arr firstObject];
//    
//    [calloutView updateCellWithDistanceString:plantomaticAnnotation.distance addressString:plantomaticAnnotation.address];
//    
//    calloutView.center = CGPointMake(view.bounds.size.width / 2, -calloutView.bounds.size.height*0.52);
//    [view addSubview:calloutView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(calloutTapped:)];
    [view addGestureRecognizer:tapGesture];

}

-(void)calloutTapped:(UITapGestureRecognizer *) sender
{
    NSLog(@"Callout was tapped");
    
    MKAnnotationView *view = (MKAnnotationView*)sender.view;
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // create an alert controller with action sheet appearance
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"PlantOMatic" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // create the actions handled by each button
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Use GPS location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Use GPS location");
            
            [self dismissViewControllerAnimated:true completion:^{
                [Utility removeUserSelectedLocation];
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
            }];
            
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Use Pin location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Use Pin location");
            
            [self dismissViewControllerAnimated:true completion:^{
                [Utility setUserSelectedLocation:annotation.coordinate];
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
            }];
            
        }];

        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Draw route to Pin location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Draw route from current GPS location to Pin location");
            
            [self dismissViewControllerAnimated:true completion:^{
                ///create MKMapItem out of coordinates
                MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil];
                MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
                [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
            }];
            
        }];

        UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"Close Map without any action" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Close Map without any action");
            
            [self dismissViewControllerAnimated:true completion:^{
                if ([Utility isUserHaveSelectedAnyLocation]==false)
                {
                    //Refresh only when GPS current location is selected.
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
                }
            }];
        }];

        UIAlertAction *action5= [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Cancel");
        }];
        
        // add actions to our sheet
        [actionSheet addAction:action1];
        [actionSheet addAction:action2];
        [actionSheet addAction:action3];
        [actionSheet addAction:action4];
        [actionSheet addAction:action5];

        // bring up the action sheet
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}



- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
//     [mapView deselectAnnotation:view.annotation animated:YES];

//    if ( [view isKindOfClass:[CustomCalloutView class]] ) {
//        for (UIView *subview in view.subviews) {
//            [subview removeFromSuperview];
//        }
//    }
}


- (void) getPlacemarkFromLocation:(CLLocation*)location {
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(error)
             NSLog(@">>>>>>>> Error in reverseGeoLocation - %@", [error localizedDescription]);
         
         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark* placemark = [placemarks lastObject];
             MKPlacemark *selectedItem = [[MKPlacemark alloc] initWithPlacemark:placemark];
             NSString* addressString =[Utility parseAddress:selectedItem];
             
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MBDidReceiveAddressNotification"
                                                                object:self
                                                              userInfo:@{ @"address" : addressString }];

         }
     }];
}

-(void)receiveAddressNotification:(NSNotification*)notification
{
    NSString* address = [notification.userInfo objectForKey:@"address"];
    self.point.title = address;
}


- (IBAction)closeAction:(id)sender {
    // create an alert controller with action sheet appearance
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"PlantOMatic" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // create the actions handled by each button
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Use GPS location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Use GPS location");
        
        [self dismissViewControllerAnimated:true completion:^{
            //dont do anything here
            [Utility removeUserSelectedLocation];
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
        }];
        
    }];

    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Close Map without any action" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Close Map without any action");
        
        [self dismissViewControllerAnimated:true completion:^{
            if ([Utility isUserHaveSelectedAnyLocation]==false)
            {
                //Refresh only when GPS current location is selected.
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
            }
        }];
        
    }];

    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel");
    }];
    
    // add actions to our sheet
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    [actionSheet addAction:action3];
    
    // bring up the action sheet
    [self presentViewController:actionSheet animated:YES completion:nil];
}



- (void)dropPinZoomIn:(MKPlacemark *)placemark
              address:(NSString*)address
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    self.searchPoint.coordinate = placemark.coordinate;
    self.searchPoint.title = address;
    
    float distance =[self.mapView.userLocation.location distanceFromLocation:[[CLLocation alloc]initWithLatitude:placemark.coordinate.latitude longitude:placemark.coordinate.longitude]];
    
    if ( distance >= 1000 )  {
        //use km unit
        self.searchPoint.subtitle= [NSString stringWithFormat:@"%.02f km",distance/1000];
    }
    else {
        //use m
        self.searchPoint.subtitle= [NSString stringWithFormat:@"%.0f meter",distance];
    }
    
    [self.mapView addAnnotation:self.searchPoint];
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:self.searchPoint animated:YES];
}



@end