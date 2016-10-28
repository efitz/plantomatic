
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
#import "LocationSearchTableViewController.h"
#import "Utility.h"
#import "PinAnnotation.h"
#import "CalloutAnnotationView.h"
#import "AppDelegate.h"

@interface CustomMapVIewController()<UIGestureRecognizerDelegate,MKMapViewDelegate,HandleMapSearch, CalloutAnnotationViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PinAnnotation *point;
@property (strong, nonatomic) PinAnnotation *searchPoint;
@property (strong, nonatomic) UISearchController *resultSearchController;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@property (readwrite, nonatomic) BOOL isFirstTime;
@property (readwrite, nonatomic) BOOL isSafeToChangeCenterCoordinates;
@property (strong, nonatomic) IBOutlet UIView *searchView;

@end

@implementation CustomMapVIewController

- (void)viewDidLoad
{
    self.title = @"Choose location"; //Plants of the Americas
    
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
    self.point = [[PinAnnotation alloc] init];
    self.point.title = @"";
    self.searchPoint = [[PinAnnotation alloc] init];
    self.searchPoint.title = @"";
    
    self.isFirstTime = true;
    self.isSafeToChangeCenterCoordinates = true;
    ///////////////////////////////////////////////////////////////////
    //// This part brings back to user to last time selected location
    ///////////////////////////////////////////////////////////////////

    if ([Utility isUserHaveSelectedAnyLocation]==true)
    {
        CLLocation* currentLocation = [Utility getCurrentLocation];

        [self getPlacemarkFromLocation:currentLocation];
        
        [self.point setCoordinate:currentLocation.coordinate];
        self.point.address = [NSString stringWithFormat:@"latitude:%.02f longitude:%.02f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
        
        
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
    [self.searchView addSubview:self.resultSearchController.searchBar];
    self.resultSearchController.hidesNavigationBarDuringPresentation = false;
    self.resultSearchController.dimsBackgroundDuringPresentation = true;

    self.definesPresentationContext = true;
    locationSearchTable.mapView = self.mapView;
    locationSearchTable.handleMapSearchDelegate = self;
    
    UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeAction:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
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
        self.point.address = [NSString stringWithFormat:@"latitude:%.02f longitude:%.02f",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
        
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
        
        self.isSafeToChangeCenterCoordinates = false;

        [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
        
        self.isSafeToChangeCenterCoordinates = true;
    }
}

#pragma mark
#pragma mark Custom methods

//---------------------------------------------------------------

- (void)calloutButtonClicked:(NSString *)title {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"More info" message:title delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    
}


#pragma mark
#pragma mark MKMapView delegate methods

//---------------------------------------------------------------

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView;
    NSString *identifier;
    
    if ([annotation isKindOfClass:[PinAnnotation class]]) {
        // Pin annotation.
        identifier = @"Pin";
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else
        {
            PinAnnotation *pinAnnotation = ((PinAnnotation *)annotation);
            [mapView removeAnnotation:pinAnnotation.calloutAnnotation];
            pinAnnotation.calloutAnnotation = nil;
        }
    } else if ([annotation isKindOfClass:[CalloutAnnotation class]]) {
        // Callout annotation.
        identifier = @"Callout";
        annotationView = (CalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[CalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        CalloutAnnotation *calloutAnnotation = (CalloutAnnotation *)annotation;
        
        ((CalloutAnnotationView *)annotationView).title = calloutAnnotation.title;
        ((CalloutAnnotationView *)annotationView).delegate = self;
        [annotationView setNeedsDisplay];
        
        
        [annotationView setCenterOffset:CGPointMake(0, -60)];
        // Move the display position of MapView.
        
        if ( self.isSafeToChangeCenterCoordinates ){
            [UIView animateWithDuration:0.5f
                             animations:^(void) {
                                 mapView.centerCoordinate = calloutAnnotation.coordinate;
                             }];
        }

    }
    
    annotationView.annotation = annotation;
    
    return annotationView;
}

//---------------------------------------------------------------

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[PinAnnotation class]]) {
        // Selected the pin annotation.
        CalloutAnnotation *calloutAnnotation = [[CalloutAnnotation alloc] init];
        
        PinAnnotation *pinAnnotation = ((PinAnnotation *)view.annotation);
        calloutAnnotation.title = [[NSString alloc] initWithFormat:@"%@",pinAnnotation.address];

        calloutAnnotation.coordinate = pinAnnotation.coordinate;
        pinAnnotation.calloutAnnotation = calloutAnnotation;
        [mapView addAnnotation:calloutAnnotation];
    }
}

//---------------------------------------------------------------

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[PinAnnotation class]]) {
        // Deselected the pin annotation.
        PinAnnotation *pinAnnotation = ((PinAnnotation *)view.annotation);
        
        [mapView removeAnnotation:pinAnnotation.calloutAnnotation];
        
        pinAnnotation.calloutAnnotation = nil;
    }
}

//---------------------------------------------------------------



- (void)goButtonClicked:(CalloutAnnotation*)annotation
{
    [self dismissViewControllerAnimated:true completion:^{
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.isComingFromWelcome = false;
        
        [Utility setUserSelectedLocation:annotation.coordinate];
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
    }];
}


- (void)moreInfoButtonClicked:(CalloutAnnotation*)annotation
{
    NSLog(@"Callout was tapped");
    if ([annotation isKindOfClass:[CalloutAnnotation class]])
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
            
//            [self dismissViewControllerAnimated:true completion:^{
                ///create MKMapItem out of coordinates
                MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil];
                MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
                [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
//            }];
            
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
    self.point.address = address;
    self.point.calloutAnnotation.title = [[NSString alloc] initWithFormat:@"%@",self.point.address];


    
    CalloutAnnotationView* annotationView = (CalloutAnnotationView*)[self.mapView viewForAnnotation:self.point.calloutAnnotation];
    annotationView.titleLabel.text = self.point.calloutAnnotation.title;

//    [self.mapView removeAnnotation:self.point.calloutAnnotation];
//    [self.mapView addAnnotation:self.point.calloutAnnotation];
}


- (IBAction)closeAction:(id)sender {
    // create an alert controller with action sheet appearance
    
    [self dismissViewControllerAnimated:true completion:^{
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if ([Utility isUserHaveSelectedAnyLocation]==false || appDelegate.isComingFromWelcome ==true)
        {
            //Refresh only when GPS current location is selected.
            appDelegate.isComingFromWelcome =false;
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
        }
    }];
}



- (void)dropPinZoomIn:(MKPlacemark *)placemark
              address:(NSString*)address
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    self.searchPoint.coordinate = placemark.coordinate;
    
    [self.mapView removeAnnotation:self.searchPoint.calloutAnnotation];
    self.point.calloutAnnotation = nil;
    [self.mapView removeAnnotation:self.searchPoint];

    self.searchPoint.address = address;

    [self.mapView removeAnnotation:self.point.calloutAnnotation];
    self.point.calloutAnnotation = nil;

    
    
    [self.mapView addAnnotation:self.searchPoint];
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:self.searchPoint animated:YES];
}

- (IBAction)toggleLocation:(id)sender {
    
    CLLocationCoordinate2D coordinate = self.mapView.userLocation.location.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    [self getPlacemarkFromLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
    
    [self.point setCoordinate:coordinate];
    self.point.address = [NSString stringWithFormat:@"latitude:%.02f longitude:%.02f",coordinate.latitude,coordinate.longitude];
    
    [self.mapView addAnnotation:self.point];
    [self.mapView selectAnnotation:self.point animated:YES];
}


@end
