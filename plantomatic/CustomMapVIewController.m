
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


@interface CustomMapVIewController()<UIGestureRecognizerDelegate,MKMapViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchingTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *point;
@property (strong, nonatomic) MKPointAnnotation *searchPoint;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(somethingHappens:) name:@"MBDidReceiveAddressNotification" object:nil];
    self.searchingTextField.delegate = self;
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

        
        return;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
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
    pin.pinColor = MKPinAnnotationColorRed;
    pin.animatesDrop = YES;
    [pin setEnabled:YES];
    [pin setCanShowCallout:YES];

    return pin;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
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
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ( [view isKindOfClass:[CustomCalloutView class]] ) {
        for (UIView *subview in view.subviews) {
            [subview removeFromSuperview];
        }
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
             
             
//              NSString *address = [NSString stringWithFormat:@"%@ %@,%@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
             
             NSMutableString* addressString = [[NSMutableString alloc] initWithString:@""];
             
             if ( [placemark subThoroughfare] != nil ) {
                 [addressString appendString:[placemark subThoroughfare]];
             }
             
             
             if ( [placemark subThoroughfare] != nil ) {
                 
                 if ( [addressString length] > 0 ) {
                     [addressString appendString:@" "];
                 }
                 
                 [addressString appendString:[placemark thoroughfare]];
             }
             
             if ( [placemark locality] != nil ) {
                 
                 if ( [addressString length] > 0 ) {
                     [addressString appendString:@", "];
                 }
                 
                 [addressString appendString:[placemark locality]];
             }
             
             if ( [placemark administrativeArea] != nil ) {
                 
                 if ( [addressString length] > 0 ) {
                     [addressString appendString:@" "];
                 }
                 
                 [addressString appendString:[placemark administrativeArea]];
             }
             
             
             
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MBDidReceiveAddressNotification"
                                                                object:self
                                                              userInfo:@{ @"address" : addressString }];

         }
     }];
}






-(void)somethingHappens:(NSNotification*)notification
{
    NSString* address = [notification.userInfo objectForKey:@"address"];
    self.point.title = address;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor whiteColor];
    [self getLocationFromAddress:textField.text];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
    [self getLocationFromAddress:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [self getLocationFromAddress:textField.text];
    [textField resignFirstResponder];
    return YES;
}
-(void) getLocationFromAddress:(NSString *)address {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
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
                         [self.mapView selectAnnotation:self.searchPoint animated:YES];

                         
                         [self.mapView setRegion:region animated:YES];
                         [self.mapView selectAnnotation:self.searchPoint animated:YES];

                     }
                 }
     ];
}

- (IBAction)closeAction:(id)sender {
    // create an alert controller with action sheet appearance
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"PlantOMatic" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // create the actions handled by each button
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Proceed with current location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Proceed with current location");
        
        [self dismissViewControllerAnimated:true completion:^{
            //dont do anything here
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];
        }];
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel");
    }];
    
    // add actions to our sheet
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    
    // bring up the action sheet
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end