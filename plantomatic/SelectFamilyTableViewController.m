//
//  SelectFamilyTableViewController.m
//  plantomatic
//
//  Created by developer on 2/16/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import "SelectFamilyTableViewController.h"
#import "FMDBDataAccess.h"
#include "proj_api.h"
#import <CoreLocation/CoreLocation.h>
#import "Utility.h"

@interface SelectFamilyTableViewController ()

@property(nonatomic, strong) NSMutableArray* families;

@end

@implementation SelectFamilyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    CLLocation *currentLocation=[Utility getCurrentLocation];
    
    double lat1=currentLocation.coordinate.latitude, lon1=currentLocation.coordinate.longitude;
    double lat, lon;
    //Need to convert the input coordinates into radians
    lat = DEGREES_TO_RADIANS(lat1);
    lon = DEGREES_TO_RADIANS(lon1);
    
    //Initiate the destination projection using the  Lambert Equal Area projection with proper offsets
    projPJ dst_prj = pj_init_plus("+proj=laea +lat_0=15 +lon_0=-80 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0");
    
    //Initiate the source projection
    projPJ src_prj = pj_init_plus("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs");
    
    //To transform the data
    pj_transform(src_prj, dst_prj, 1, 1, &lon, &lat, NULL);
    double X=0,Y=0,resolution=100000, corner_x=-5261554, corner_y=7165012;
    
    X = floor((lon - corner_x)/resolution + 1); //units are in meters so we need to convert output 100kM grid
    Y = floor(((lat - corner_y)/resolution * -1) + 1);
    
    /*
     Here is test data with example input and output
     1) 42.337302, -71.227067 column 61, row 42, 2117
     2) 43.478256, -110.763924 column 28, row 38, 2263 species
     3) 26.363909, -80.131706 column 53, row 60, 1087
     4) 32.243065, -110.927750 column 24, row 50, 3704 species
     */
    

    //if outside of the US set the grid to Tuscon, AZ
    if (-1*lon1 > 170 || -1*lon1 < 58) {
        Y=50;
        X=24;
    }
    
    Y=60;
    X=53;
    
    
    self.families=[db getFamiliesWithFilterForY:Y andX:X];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FAMILY_FILTER_CELL_NOTIFICATION object:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.families.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FamilyFilterCell" forIndexPath:indexPath];
    
    NSString* family=[self.families objectAtIndex:indexPath.row];
    cell.textLabel.text=family;
    
    if ([self isFamilyAlreadySelected:family])
    {
        //check mark the cell
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else
    {
        //make accessor to none
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *family = [self.families objectAtIndex:indexPath.row];

    
    NSMutableArray* familiesSelected=[[NSUserDefaults standardUserDefaults] objectForKey:@"familiesSelected"];
    
    if ([self isFamilyAlreadySelected:family])
    {
        //remove from family
        [familiesSelected removeObject:family];
    }
    else
    {
        //add to families
        [familiesSelected addObject:family];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:familiesSelected forKey:@"familiesSelected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //reload current cell
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

}

-(BOOL) isFamilyAlreadySelected:(NSString*)familyToSearch
{
    BOOL isFamilyAlreadySelected=NO;
    
    NSMutableArray* familiesSelected=[[NSUserDefaults standardUserDefaults] objectForKey:@"familiesSelected"];
    
    for (NSString* familySelected in familiesSelected) {
        
        if ([familySelected isEqualToString:familyToSearch]) {
            isFamilyAlreadySelected=YES;
            break;
        }
    }
    
    return isFamilyAlreadySelected;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
