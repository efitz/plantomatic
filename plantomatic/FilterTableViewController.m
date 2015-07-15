//
//  FilterTableViewController.m
//  plantomatic
//
//  Created by developer on 2/9/15.
//  Copyright (c) 2015 Ocotea Technologies, LLC. All rights reserved.
//

#import "FilterTableViewController.h"
#import "FilterCollectionViewTableViewCell.h"
#import "FilterWithSwitchTableViewCell.h"
#import "Constants.h"
#import "SortOrderTableViewCell.h"
#import "SelectFamilyTableViewController.h"
#import "FilterHeaderTableViewCell.h"
#import "Utility.h"
#import "FMDBDataAccess.h"
#include "proj_api.h"
#import <CoreLocation/CoreLocation.h>
#import "SpeciesFamily.h"

@interface FilterTableViewController ()

@property(nonatomic, strong) FilterHeaderTableViewCell *sectionHeaderCell;

@property(nonatomic, strong) NSMutableArray* totalAvialblePlants;

@end

@implementation FilterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:@"Filters"];
    
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(searchAction)];

    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction)];

    [self createSearchActionButton];
    
//    [self.tableView registerClass:[FilterCollectionViewTableViewCell class] forCellReuseIdentifier:@"FilterCollectionViewTableViewCell"];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(refreshFamilyFilterCell) name:REFRESH_FAMILY_FILTER_CELL_NOTIFICATION object:nil];

    
}


-(void) viewWillAppear:(BOOL)animated
{
    [self performSelectorInBackground:@selector(updateHeaderHint) withObject:nil];
//    [self updateHeaderHint];
}


-(void)updateHeaderHint
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    CLLocation *currentLocation=[Utility getCurrentLocation];
    
    if (currentLocation==nil)
    {
        //Happens in iOS8 first time after app launch get current location nil
        //so calling it again with delay of half second
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(updateHeaderHint) withObject:nil afterDelay:0.5];
        });
        
        return;
    }
    
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
    
    
    self.totalAvialblePlants=[db getPlantsForY:Y andX:X];
    
    
    [self.sectionHeaderCell updateCellWithAvailablePlants:[self getFilterPlantsNumber]
                                           andTotalPlants:[self.totalAvialblePlants count]];
}


-(int) getFilterPlantsNumber
{
    @autoreleasepool {
        int resultNumber=0;
        NSMutableArray* filteredResultArrayImageAvaialbe=[NSMutableArray array];
        
        
        NSMutableArray* filteredResultArrayGrowthForm=[NSMutableArray array];
        
        if ([self.totalAvialblePlants count]>0)
        {
            NSMutableDictionary* growthFormDictionary= [[NSUserDefaults standardUserDefaults] objectForKey:@"growthFormDictionary"];
            NSArray* growthFormKeys=[growthFormDictionary allKeys];
            NSMutableArray* growthFromArray=[NSMutableArray array];
            
            for (NSString* key in growthFormKeys) {
                
                NSDictionary* dictionary=[growthFormDictionary valueForKey:key];
                NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
                
                if (isSelected.boolValue)
                {
                    if ([key isEqualToString:@"Unknown"]) {
                        [growthFromArray addObject:@"-"];
                    }
                    else
                    {
                        [growthFromArray addObject:key];
                    }
                }
            }
            
            
            if ([growthFromArray count]>0)
            {
                for (SpeciesFamily *speciesFamily  in self.totalAvialblePlants)
                {
                    //filter objects based on keys
                    
                    for (NSString* key in growthFromArray)
                    {
                        if ([speciesFamily.habit isEqualToString:key])
                        {
                            [filteredResultArrayGrowthForm addObject:speciesFamily];
                            break;
                        }
                    }
                }
            }
            else
            {
                [filteredResultArrayGrowthForm addObjectsFromArray:self.totalAvialblePlants];
            }
            
            
            //-----------------------Growth form filtered
            
            NSMutableArray* filteredResultArrayFlowers=[NSMutableArray array];
            
            
            NSMutableDictionary* flowerColorsDictionary=[[NSUserDefaults standardUserDefaults] objectForKey:@"flowerColorsDictionary"];
            NSArray* flowerColorsKeys=[flowerColorsDictionary allKeys];
            NSMutableArray* flowerColorsArray=[NSMutableArray array];
            
            for (NSString* key in flowerColorsKeys) {
                
                NSDictionary* dictionary=[flowerColorsDictionary valueForKey:key];
                NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
                
                if (isSelected.boolValue)
                {
                    if ([key isEqualToString:@"Unknown-Flower"]) {
                        [flowerColorsArray addObject:@"-"];
                    }
                    else
                    {
                        [flowerColorsArray addObject:key];
                    }
                    
                }
            }
            
            
            if ([flowerColorsArray count]>0)
            {
                for (SpeciesFamily *speciesFamily  in filteredResultArrayGrowthForm)
                {
                    //filter objects based on keys
                    
                    for (NSString* key in flowerColorsArray)
                    {
                        if ([speciesFamily.flowerColor isEqualToString:key])
                        {
                            [filteredResultArrayFlowers addObject:speciesFamily];
                            break;
                        }
                    }
                }
            }
            else
            {
                [filteredResultArrayFlowers addObjectsFromArray:filteredResultArrayGrowthForm];
            }
            
            //        filteredResultArrayGrowthForm=nil;
            
            //-----------------------Flowers filtered
            
            NSMutableArray* filteredResultArrayFamily=[NSMutableArray array];
            
            
            NSMutableArray* familiesSelected=[[NSUserDefaults standardUserDefaults] objectForKey:@"familiesSelected"];
            
            
            if ([familiesSelected count]>0) {
                for (SpeciesFamily *speciesFamily  in filteredResultArrayFlowers)
                {
                    //filter objects based on keys
                    
                    for (NSString* family in familiesSelected)
                    {
                        if ([speciesFamily.family isEqualToString:family])
                        {
                            [filteredResultArrayFamily addObject:speciesFamily];
                            break;
                        }
                    }
                }
            }
            else
            {
                [filteredResultArrayFamily addObjectsFromArray:filteredResultArrayFlowers];
                
            }
            
            //        filteredResultArrayFlowers=nil;
            
            //-----------------------Family filtered
            
            NSMutableArray* filteredResultArrayCommonName=[NSMutableArray array];
            
            NSNumber *isCommonNameAvaialble = [[NSUserDefaults standardUserDefaults]
                                               valueForKey:@"isCommonNameAvailable"];
            
            if ([isCommonNameAvaialble boolValue]==YES)
            {
                for (SpeciesFamily *speciesFamily  in filteredResultArrayFamily)
                {
                    if (![speciesFamily.commonName isEqualToString:@"-"]) {
                        [filteredResultArrayCommonName addObject:speciesFamily];
                    }
                }
            }
            else
            {
                [filteredResultArrayCommonName addObjectsFromArray:filteredResultArrayFamily];
            }
            
            //        filteredResultArrayFamily=nil;
            //-----------------------CommonName filtered
            
            
            NSNumber *isImageAvailable = [[NSUserDefaults standardUserDefaults]
                                          valueForKey:@"isImageAvailable"];
            
            if ([isImageAvailable boolValue]==YES)
            {
                for (SpeciesFamily *speciesFamily  in filteredResultArrayCommonName)
                {
                    if ([speciesFamily.isImageAvailabe isEqualToString:@"TRUE"]) {
                        [filteredResultArrayImageAvaialbe addObject:speciesFamily];
                    }
                }
            }
            else
            {
                [filteredResultArrayImageAvaialbe addObjectsFromArray:filteredResultArrayFamily];
            }
            
            //        filteredResultArrayFamily=nil;
            //-----------------------isImageAvailable filtered
            
            
        }
        
        
        
        
        
        
        
        return [filteredResultArrayImageAvaialbe count];
    }
}


-(void) createSearchActionButton
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    button.frame = CGRectMake(0.0, 0.0, 60.0f, 30.0f);
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"%@", button.titleLabel.font);
    CALayer *doneBtnLayer = [button layer];
    [doneBtnLayer setMasksToBounds:YES];
//    [doneBtnLayer setCornerRadius:5.0f];
    
    NSString* buttonTitle=@"Search";
    SEL action=@selector(searchAction);
    
//    button.backgroundColor=[UIColor colorWithRed:162.0/255.0 green:216.0/255.0 blue:131.0/255.0 alpha:1.0];

    button.backgroundColor=[UIColor colorWithRed:17.0/255.0 green:115.0/255.0 blue:186.0/255.0 alpha:1.0];

    //sortOrderBtn
    CALayer *btnLayer = [button layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    btnLayer.borderWidth=1;
    btnLayer.borderColor=[[UIColor whiteColor] CGColor];

    
//    [button setBackgroundImage:[UIImage imageNamed:@"btn-tag-blue"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(buttonTitle, nil) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -9;// it was -6 in iOS 6
    
    UIBarButtonItem *searchActionButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, searchActionButton/*this will be the button which u actually need*/, nil] animated:NO];

//    [self.navigationItem setRightBarButtonItem:searchActionButton];
}



-(void)refreshFamilyFilterCell
{
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];

    
//    [self.sectionHeaderCell updateCellWithAvailablePlants:9 andTotalPlants:1000];
    
    [self.tableView reloadData];

}



-(void) searchAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];

    }];
    
}

-(void) cancelAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NOTIFICATION object:nil];

    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell* filterHeaderTableViewCell=nil;
    
    if (section==0)
    {
        if (_sectionHeaderCell==nil) {
            self.sectionHeaderCell = [tableView dequeueReusableCellWithIdentifier:@"FilterHeaderTableViewCell"];
        }
        
//        if ([Utility isAppUsingDefaultSettings]) {
//            filterHeaderTableViewCell=nil;
//        }
//        else
//        {
            filterHeaderTableViewCell=self.sectionHeaderCell;
//        }
    }
//    else
//    {
//         filterHeaderTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"SectionHeaderCell"];
//    }

    [self performSelectorInBackground:@selector(updateHeaderHint) withObject:nil];

//    [self updateHeaderHint];

    
    return filterHeaderTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight=32.0;
    
    if (![Utility isAppUsingDefaultSettings] && section==0)
    {
        headerHeight=60.0;
    }
    
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=44;
    
    if (indexPath.row==0 && indexPath.section==0) {
        height=[self FilterCellHeightForRowAtIndexPath:indexPath];
    }
    else if (indexPath.row==1 && indexPath.section==0)
    {
        height=[self FilterCellHeightForRowAtIndexPath:indexPath];
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 8;
}

-(NSMutableArray*) getGrowthForms
{
    //GROWTH_FORM
    NSMutableArray* array=[NSMutableArray array];
    
    for (int i=0; i<[GROWTH_FORM count]; i++) {
        
        NSString* key=[GROWTH_FORM objectAtIndex:i];
        
        for (SpeciesFamily *speciesFamily  in self.totalAvialblePlants)
        {
            //filter objects based on keys
            
            if ([key isEqualToString:@"Unknown"]) {
                key=@"-";
            }
            
            if ([[speciesFamily.habit capitalizedString] isEqualToString:key])
            {
                if ([key isEqualToString:@"-"])
                {
                    [array addObject:@"Unknown"];
                }
                else
                {
                    [array addObject:key];
                }
                
                
                break;
            }
        }
    }
    
    return array;
}

-(NSMutableArray*) getFlowerColors
{
    //FLOWER_COLORS
    NSMutableArray* array=[NSMutableArray array];
    
    for (int i=0; i<[FLOWER_COLORS count]; i++) {
        
        NSString* key=[FLOWER_COLORS objectAtIndex:i];
        
        for (SpeciesFamily *speciesFamily  in self.totalAvialblePlants)
        {
            //filter objects based on keys
            
            if ([key isEqualToString:@"Unknown-Flower"]) {
                key=@"-";
            }
            
            if ([[speciesFamily.flowerColor capitalizedString] isEqualToString:key])
            {
                if ([key isEqualToString:@"-"])
                {
                    [array addObject:@"Unknown-Flower"];
                }
                else
                {
                    [array addObject:key];
                }
                
                break;
            }
        }
    }
    
    return array;
}




-(CGFloat) FilterCellHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfItems=11;
    
//    if (indexPath.row==0) {
//        numberOfItems=[[self getGrowthForms] count];
//    }
    
    if (indexPath.row==1) {
        numberOfItems=13;
//        numberOfItems=[[self getFlowerColors] count];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    int numberOfRows=ceilf(((75*numberOfItems)/(screenWidth-15)));
    CGFloat height=90*numberOfRows;
    return  height+34+10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    UITableViewCell *cell = nil;
    
    NSString* cellIdentifier=@"";
    
    //FilterCollectionViewTableViewCell
    
    if (indexPath.row==0)
    {
        cellIdentifier=@"FilterCollectionViewTableViewCell";
        FilterCollectionViewTableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (filterCell == nil) {
            filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        
        [filterCell updateCellForGrowthForm:[self growthFormDictionary] totalPlantsAvailable:self.totalAvialblePlants];
        cell=filterCell;
    }
    else if (indexPath.row==1)
    {
        cellIdentifier=@"FilterCollectionViewTableViewCell";
        FilterCollectionViewTableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (filterCell == nil) {
            filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        
        [filterCell updateCellForFlowerColors:[self flowerColorsDictionary] totalPlantsAvailable:self.totalAvialblePlants];
        cell=filterCell;
    }
    else if (indexPath.row==2)
    {
        cellIdentifier=@"SectionHeaderCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    else if (indexPath.row==3)
    {
        cellIdentifier=@"FilterWithSwitchTableViewCell";
        FilterWithSwitchTableViewCell* filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [filterCell updateCellWithFilterType:FilterTypeCommonName];
        cell=filterCell;
    }
    else if(indexPath.row==4)
    {
        cellIdentifier=@"FilterWithSwitchTableViewCell";
        FilterWithSwitchTableViewCell* filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [filterCell updateCellWithFilterType:FilterTypeImage];
        cell=filterCell;
    }
    else if(indexPath.row==5)
    {
        cellIdentifier=@"FamilyCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text=@" Family";
        
        NSMutableArray* familiesSelected=[[NSUserDefaults standardUserDefaults] objectForKey:@"familiesSelected"];
        
        if ([familiesSelected count]==0)
        {
            cell.detailTextLabel.text=@"None";
        }
        else
        {
            NSString *familiesSelectedString = [familiesSelected componentsJoinedByString:@", "];
            cell.detailTextLabel.text=familiesSelectedString;
        }
    }
    else if(indexPath.row==6)
    {
        cellIdentifier=@"FamilyCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text=@" Sort By";
        
        NSMutableArray* sortColumns=[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"];
        
        if ([sortColumns count]==0)
        {
            cell.detailTextLabel.text=@"None";
        }
        else
        {
            NSString *sortColumnsString = [sortColumns componentsJoinedByString:@", "];
            
            if ([sortColumnsString isEqualToString:@"Habit"]) {
                sortColumnsString=@"Growth Form";
            }
            else if ([sortColumnsString isEqualToString:@"Flower_Color"]) {
                sortColumnsString=@"Flower Color";
            }
            else if ([sortColumnsString isEqualToString:@"Common_Name"]) {
                sortColumnsString=@"Common Name";
            }
            
            cell.detailTextLabel.text=sortColumnsString;
        }
    }
    
    else if(indexPath.row==7)
    {
        cellIdentifier=@"SortOrderTableViewCell";
        SortOrderTableViewCell* filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [filterCell updateCell];
        cell=filterCell;
    }
    
    // Configure the cell...
    
    return cell;
}


-(NSMutableDictionary*) growthFormDictionary
{
    
    NSMutableDictionary *growthFormDictionary = [[NSUserDefaults standardUserDefaults]
                                          valueForKey:@"growthFormDictionary"];

    if (growthFormDictionary==nil)
    {
        
        growthFormDictionary=[@{@"Aquatic":@{@"isSelected":@NO},
                               @"Bryophyte":@{@"isSelected":@NO},
                               @"Cactus":@{@"isSelected":@NO},
                               @"Epiphyte":@{@"isSelected":@NO},
                               @"Fern": @{@"isSelected":@NO},
                               @"Grass":@{@"isSelected":@NO},
                               @"Herb": @{ @"isSelected":@NO},
                               @"Parasite":@{@"isSelected":@NO},
                               @"Shrub":@{@"isSelected":@NO},
                               @"Tree":@{@"isSelected":@NO},
                               @"Vine":@{@"isSelected":@NO},
                               @"Unknown":@{@"isSelected":@NO}} mutableCopy];

        [[NSUserDefaults standardUserDefaults] setObject:growthFormDictionary forKey:@"growthFormDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    return [growthFormDictionary mutableCopy];
}


-(NSMutableDictionary*) flowerColorsDictionary
{
    
    NSMutableDictionary *flowerColorsDictionary = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:@"flowerColorsDictionary"];
    
    if (flowerColorsDictionary==nil)
    {
        flowerColorsDictionary=[@{@"Red":@{@"isSelected":@NO},
                                 @"Pink":@{@"isSelected":@NO},
                                 @"Violet":@{@"isSelected":@NO},
                                 @"Purple": @{@"isSelected":@NO},
                                 @"Blue":@{@"isSelected":@NO},
                                 @"Green": @{ @"isSelected":@NO},
                                 @"Yellow":@{@"isSelected":@NO},
                                 @"Orange":@{@"isSelected":@NO},
                                 @"Brown":@{@"isSelected":@NO},
                                 @"Gray":@{@"isSelected":@NO},
                                 @"Black":@{@"isSelected":@NO},
                                 @"White":@{@"isSelected":@NO},
                                 @"Unknown-Flower":@{@"isSelected":@NO}
                                 } mutableCopy];
        
        [[NSUserDefaults standardUserDefaults] setObject:flowerColorsDictionary forKey:@"flowerColorsDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return [flowerColorsDictionary mutableCopy];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showFilterOptions"]) {
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        //For ios7 we get view controller but in case of ios8 it returns navigation controller
        SelectFamilyTableViewController* selectFamilyTableViewController = segue.destinationViewController;
        
        if ([selectFamilyTableViewController isKindOfClass:[UINavigationController class]]) {
            //For ios8 we get navigation controller instead of view controller
            UINavigationController* navigationController=(UINavigationController*)selectFamilyTableViewController;
            selectFamilyTableViewController=(SelectFamilyTableViewController*)navigationController.topViewController;
        }
        
        BOOL isForFamily=YES;
        
        if (indexPath.row==6) {
            isForFamily=NO;
        }
        
        selectFamilyTableViewController.isForFamilyValues=isForFamily;
    }
}


@end
