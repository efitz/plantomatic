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

@interface FilterTableViewController ()

@end

@implementation FilterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:@"Filters"];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleBordered target:self action:@selector(searchAction)];

    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction)];

//    [self.tableView registerClass:[FilterCollectionViewTableViewCell class] forCellReuseIdentifier:@"FilterCollectionViewTableViewCell"];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(refreshFamilyFilterCell) name:REFRESH_FAMILY_FILTER_CELL_NOTIFICATION object:nil];

    
}

-(void)refreshFamilyFilterCell
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=44;
    
    if (indexPath.row==0) {
        height=[self FilterCellHeightForRowAtIndexPath:indexPath];
    }
    else if (indexPath.row==1)
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
    return 7;
}


-(CGFloat) FilterCellHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int numberOfItems=11;
    
    if (indexPath.row==1) {
        numberOfItems=13;
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
        
        [filterCell updateCellForGrowthForm:[self growthFormDictionary]];
        cell=filterCell;
    }
    else if (indexPath.row==1)
    {
        cellIdentifier=@"FilterCollectionViewTableViewCell";
        FilterCollectionViewTableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (filterCell == nil) {
            filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        
        [filterCell updateCellForFlowerColors:[self flowerColorsDictionary]];
        cell=filterCell;
    }
    else if (indexPath.row==2)
    {
        cellIdentifier=@"FilterWithSwitchTableViewCell";
        FilterWithSwitchTableViewCell* filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [filterCell updateCellWithFilterType:FilterTypeCommonName];
        cell=filterCell;
    }
    else if(indexPath.row==3)
    {
        cellIdentifier=@"FilterWithSwitchTableViewCell";
        FilterWithSwitchTableViewCell* filterCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [filterCell updateCellWithFilterType:FilterTypeImage];
        cell=filterCell;
    }
    else if(indexPath.row==4)
    {
        cellIdentifier=@"FamilyCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text=@"Family";
        
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
    else if(indexPath.row==5)
    {
        cellIdentifier=@"FamilyCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text=@"Sort Field";

        NSMutableArray* sortColumns=[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"];

        if ([sortColumns count]==0)
        {
            cell.detailTextLabel.text=@"None";
        }
        else
        {
            NSString *sortColumnsString = [sortColumns componentsJoinedByString:@", "];
            cell.detailTextLabel.text=sortColumnsString;
        }
    }

    else if(indexPath.row==6)
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
        UINavigationController *navigationController = segue.destinationViewController;
        SelectFamilyTableViewController* selectFamilyTableViewController=(SelectFamilyTableViewController*)navigationController.topViewController;
        
        BOOL isForFamily=YES;
        
        if (indexPath.row==5) {
            isForFamily=NO;
        }
        
        selectFamilyTableViewController.isForFamilyValues=isForFamily;
    }
}


@end
