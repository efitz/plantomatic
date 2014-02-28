//
//  PlantsViewController.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "PlantsViewController.h"
#import "FMDBDataAccess.h"
#import "SpeciesFamily.h"
#import "Utility.h"
#import "constants.h"   
#include "proj_api.h"


@interface PlantsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *plantsCountLbl;
@property (strong, nonatomic) IBOutlet UIButton *sortOrderBtn;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIControl *pickerControl;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UILabel *criteriaLbl;


@property (nonatomic, readwrite) int pickerViewSelectedIndex;

@property (nonatomic,strong) NSMutableArray* plantsSearchResultArray;

@end

@implementation PlantsViewController

@synthesize plants;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.plantsSearchResultArray=[NSMutableArray array];
    
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.hidesBackButton = YES;
    
    self.pickerControl.hidden=YES;
    self.toolbar.hidden=YES;
    
    NSNumber *sortOrder = [[NSUserDefaults standardUserDefaults]
                            valueForKey:@"sortOrder"];
    
    
    if (sortOrder==nil) {
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithBool:YES] forKey:@"sortOrder"];
        
        [self.sortOrderBtn setImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
    }
    else
    {
        if (sortOrder.boolValue) {
            [self.sortOrderBtn setImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.sortOrderBtn setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
        }
        
    }
    
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                           valueForKey:@"sortCriteria"];

    
    if (sortOrder==nil) {
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithInteger:0] forKey:@"sortCriteria"];
        
        self.criteriaLbl.text=@"Family";
        [self.sortOrderBtn setImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        
        self.pickerViewSelectedIndex=0;
    }
    else
    {
        
        switch (sortCriteria.integerValue) {
            case FilterByValueFamily:
                self.criteriaLbl.text=@"Family";
                break;
            case FilterByValueGenus:
                self.criteriaLbl.text=@"Genus";
                break;
            case FilterByValueSpecies:
                self.criteriaLbl.text=@"Species";
                break;
                
            default:
                break;
        }
    }

    self.pickerViewSelectedIndex=sortCriteria.integerValue;

    
    
    
    [self populatePlants];
}


-(void) showPicker
{
    self.pickerControl.hidden=NO;
    self.toolbar.hidden=NO;

    
    [self.pickerView selectRow:self.pickerViewSelectedIndex inComponent:0 animated:YES];
}


-(void) hidePicker
{
    self.pickerControl.hidden=YES;
    self.toolbar.hidden=YES;
}


-(void) populatePlants
{
    NSNumber *sortOrder = [[NSUserDefaults standardUserDefaults]
                           valueForKey:@"sortOrder"];
    
    self.plants = [[NSMutableArray alloc] init];
    
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    CLLocation *currentLocation=[Utility getCurrentLocation];
    
    double lat=currentLocation.coordinate.latitude, lon=currentLocation.coordinate.longitude;
	//Need to convert the input coordinates into radians
	lat = DEGREES_TO_RADIANS(lat);
	lon = DEGREES_TO_RADIANS(lon);
    
    //Initiate the destination projection using the  Lambert Equal Area projection with proper offsets
	projPJ dst_prj = pj_init_plus("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs");
    
    //Initiate the source projection
    projPJ src_prj = pj_init_plus("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs");
    
    //To transform the data
    pj_transform(src_prj, dst_prj, 1, 1, &lon, &lat, NULL);
    double X=0,Y=0;

    X = lon/100000; //units are in meters so we need to convert output 100kM grid
	Y = lat/100000;

    
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    
    //self.plants = [db getPlantsForY:lat andX:lon andFilterByValue:sortCriteria.integerValue isInAscendingOrder:sortOrder.boolValue];
    //Y=50, X=24
    self.plants = [db getPlantsForY:50 andX:24 andFilterByValue:sortCriteria.integerValue isInAscendingOrder:sortOrder.boolValue]; //Hardcoded to match Arizona

    pj_free(src_prj);
    pj_free(dst_prj);

    
    
    NSLog(@"Plants count = %lu",(unsigned long)self.plants.count);
    
    self.plantsCountLbl.text =[NSString stringWithFormat:@"Total: %lu",(unsigned long)self.plants.count];
    
    [self.tableView reloadData];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.topItem.title = @"Plant-O-Matic";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows=0;
    
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        rows=(int)[self.plantsSearchResultArray count];
    }
    else
    {
        rows=(int)[self.plants count];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlantCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SpeciesFamily *plant = nil;
    
    
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        plant = [self.plantsSearchResultArray objectAtIndex:[indexPath row]];
    }
    else
    {
        plant = [self.plants objectAtIndex:[indexPath row]];
    }

    
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ %@",plant.genus,plant.species]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ ",plant.family]];

    
    return cell;
}

- (IBAction)showSortOptions:(id)sender {
   
    [self showPicker];
    
    //[Utility showAlert:@"" message:@"Under Contstruction..."];
}


- (IBAction)toggleSortOrder:(id)sender {
    
    NSNumber *sortOrder = [[NSUserDefaults standardUserDefaults]
                           valueForKey:@"sortOrder"];
    
    if (sortOrder.boolValue) {
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithBool:NO] forKey:@"sortOrder"];
        
        [self.sortOrderBtn setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithBool:YES] forKey:@"sortOrder"];
        
        [self.sortOrderBtn setImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self populatePlants];
}

- (IBAction)refreshResults:(id)sender {
    [self populatePlants];
}



#pragma mark - UIPickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

#pragma mark - UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString* pickerValueString=@"";
    
    switch (row) {
        case FilterByValueFamily:
            pickerValueString=@"Family";
            break;
        case FilterByValueGenus:
            pickerValueString=@"Genus";
            break;
        case FilterByValueSpecies:
            pickerValueString=@"Species";
            break;
            
        default:
            pickerValueString=@"Family";
            break;
    }
    
    return pickerValueString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickerViewSelectedIndex =row;
}

- (IBAction)hidePickerAction:(id)sender {
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    self.pickerViewSelectedIndex =sortCriteria.integerValue;
    
    [self hidePicker];
}

- (IBAction)doneAction:(id)sender {
    [self hidePicker];
    
    
    self.pickerViewSelectedIndex=[self.pickerView selectedRowInComponent:0];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSNumber numberWithInteger:self.pickerViewSelectedIndex] forKey:@"sortCriteria"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    switch (self.pickerViewSelectedIndex) {
        case FilterByValueFamily:
            self.criteriaLbl.text=@"Family";
            break;
        case FilterByValueGenus:
            self.criteriaLbl.text=@"Genus";
            break;
        case FilterByValueSpecies:
            self.criteriaLbl.text=@"Species";
            break;
            
        default:
            break;
    }

    
    [self populatePlants];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
//    self.isSearchOn=YES;
    [self.tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self handleSearchForTerm:searchString];
    
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
//    self.isSearchOn=NO;
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Search Method

- (void) handleSearchForTerm:(NSString *) searchString {
    
    //First get all the objects which fulfill the criteria
    //Then update regarding dictionary
    
    NSString *trimmedsearchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    
    [[self plantsSearchResultArray] removeAllObjects];
    for (SpeciesFamily *plant in [self plants])
    {
        
        switch (self.pickerViewSelectedIndex)
        {
            case FilterByValueFamily:
                //Search in Family
                if ([trimmedsearchString length]>0) {
                    
                    if ([[plant family] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        //add plant
                        [self.plantsSearchResultArray addObject:plant];
                    }
                }
                break;
                
            case FilterByValueGenus:
                //Search in Genus
                if ([trimmedsearchString length]>0) {
                    
                    if ([[plant genus] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        //add plant
                        [self.plantsSearchResultArray addObject:plant];
                    }
                }
                break;
                
            case FilterByValueSpecies:
                //Search in Species
                if ([trimmedsearchString length]>0) {
                    
                    if ([[plant species] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        //add plant
                        [self.plantsSearchResultArray addObject:plant];
                    }
                }
                break;
                
            default:
                break;
        }
    }
    
    
    
}




@end
