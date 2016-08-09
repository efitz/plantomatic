//
//  LocationSearchTable1.m
//  plantomatic
//
//  Created by developer on 8/9/16.
//  Copyright © 2016 Ocotea Technologies, LLC. All rights reserved.
//

#import "LocationSearchTableViewController.h"
#import "Utility.h"

@interface LocationSearchTableViewController ()<UISearchResultsUpdating>
@property (strong, nonatomic) NSString* address;

@end

@implementation LocationSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matchingItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CLPlacemark *result = [self.matchingItems objectAtIndex:indexPath.row];
    MKPlacemark *selectedItem = [[MKPlacemark alloc] initWithPlacemark:result];
    cell.textLabel.text = selectedItem.name;
    cell.detailTextLabel.text = [Utility parseAddress:selectedItem];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLPlacemark *result = [self.matchingItems objectAtIndex:indexPath.row];
    MKPlacemark *selectedItem = [[MKPlacemark alloc] initWithPlacemark:result];

    [self.handleMapSearchDelegate dropPinZoomIn:selectedItem address:self.address];
    [self dismissViewControllerAnimated:true completion:^{
        //no code here
    }];
}

#pragma mark - UISearchResultsUpdating


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if(![searchController.searchBar.text isEqual:@""] && searchController.searchBar.text.length > 0 )
    {
        [self getLocationFromAddress:searchController.searchBar.text];
    }
}

-(void) getLocationFromAddress:(NSString *)address {
    
    self.address = address;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         self.matchingItems = placemarks;
                         [self.tableView reloadData];
                     }
                 }
     ];
}


@end
