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
#import "PlantCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"


@interface PlantsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *plantsCountLbl;
@property (strong, nonatomic) IBOutlet UIButton *sortOrderBtn;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIControl *pickerControl;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIButton *criteriaSortBtn;


@property (nonatomic, readwrite) int pickerViewSelectedIndex;

@property (nonatomic,strong) NSMutableArray* plantsSearchResultArray;
@property (nonatomic, retain) NSMutableDictionary *plantsSearchResultDictionary;

@property (nonatomic,strong) NSMutableArray *plants;
@property (nonatomic, retain) NSMutableDictionary *plantsResultDictionary;


@property (nonatomic, readwrite) BOOL isSearchOn;


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
    
    self.isSearchOn=NO;
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
        
        [self.criteriaSortBtn setTitle:@"Family" forState:UIControlStateNormal];
        
        [self.sortOrderBtn setImage:[UIImage imageNamed:@"up.png"] forState:UIControlStateNormal];
        
        self.pickerViewSelectedIndex=0;
    }
    else
    {
        
        switch (sortCriteria.integerValue) {
            case FilterByValueFamily:
                [self.criteriaSortBtn setTitle:@"Family" forState:UIControlStateNormal];
                break;
                
            case FilterByValueGenus:
                [self.criteriaSortBtn setTitle:@"Genus" forState:UIControlStateNormal];
                break;
                
            case FilterByValueClassification:
                [self.criteriaSortBtn setTitle:@"Classification" forState:UIControlStateNormal];
                break;

                
            default:
                break;
        }
    }

    self.pickerViewSelectedIndex=sortCriteria.integerValue;

    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor lightGrayColor]];
    
    [self populatePlantsWrapper];
    
    [self hidePicker];
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
    
    //[self hideSearchBar];

//    if (self.pickerViewSelectedIndex==FilterByValueClassification) {
//        self.searchDisplayController.searchBar.userInteractionEnabled=NO;
//        self.searchDisplayController.searchBar.placeholder=@"Search Not Allowed.";
//    }
//    else
//    {
//        self.searchDisplayController.searchBar.userInteractionEnabled=YES;
//        self.searchDisplayController.searchBar.placeholder=@"Search";
//
//    }
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

    
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    
    //self.plants = [db getPlantsForY:lat andX:lon andFilterByValue:sortCriteria.integerValue isInAscendingOrder:sortOrder.boolValue];
    Y=60;
    X=53;
    self.plants = [db getPlantsForY:Y andX:X andFilterByValue:sortCriteria.integerValue isInAscendingOrder:sortOrder.boolValue]; //Hardcoded to match Arizona

    pj_free(src_prj);
    pj_free(dst_prj);

    NSLog(@"Plants count = %lu",(unsigned long)self.plants.count);
    
    self.plantsResultDictionary=[NSMutableDictionary dictionary];

    // iterate over the values in the raw elements dictionary
	for (SpeciesFamily *plant in self.plants)
	{
        
        NSString *firstLetter =@"";
        
        switch (sortCriteria.integerValue) {
            case FilterByValueFamily:
                //Family
                // get the element's initial letter
                firstLetter = [plant.family substringToIndex:1];
                
                break;
            case FilterByValueGenus:
                //Genus
                // get the element's initial letter
                firstLetter = [plant.genus substringToIndex:1];
                
                break;
            case FilterByValueClassification:
                //Classification
                firstLetter = [plant.classification substringToIndex:1];
                
                
                break;
                
            default:
                //Family
                
                break;
        }

        NSMutableArray *existingArray;
        
        if ([Utility isNumeric:firstLetter]) {
            firstLetter=@"Z#";
        }

		// if an array already exists in the name index dictionary
		// simply add the element to it, otherwise create an array
		// and add it to the name index dictionary with the letter as the key
		if ((existingArray = [self.plantsResultDictionary valueForKey:[firstLetter uppercaseString]]))
		{
            [existingArray addObject:plant];
		} else {
			NSMutableArray *tempArray = [NSMutableArray array];
			[self.plantsResultDictionary setObject:tempArray forKey:[firstLetter uppercaseString]];
			[tempArray addObject:plant];
		}
	}

    self.plantsCountLbl.text =[NSString stringWithFormat:@"Total: %lu",(unsigned long)self.plants.count];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    
    //To make sure the use sees the loading indicator where query taken very short time
    NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1.0 ];
    [NSThread sleepUntilDate:future];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.topItem.title = @"Plant-O-Matic";
    
    
    if ([self.searchDisplayController.searchBar.text length] == 0)
    {
        self.plantsSearchResultArray = [NSMutableArray array];
        self.plantsSearchResultDictionary = [NSMutableDictionary dictionary];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    // returns the array of section titles. There is one entry for each unique character that an element begins with
    // [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
    
    NSArray* sortedNamesArray=nil;
    
    if (!self.isSearchOn) {
        sortedNamesArray= [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		
    }
    else{
    }
    
    return sortedNamesArray;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has multiple sections. One for each unique character that an element begins with
	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
	// return the letter that represents the requested section
	// this is actually a delegate method, but we forward the request to the datasource in the view controller
    
    NSArray* sortedNamesArray = nil;
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        sortedNamesArray = [[self.plantsSearchResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
    } else {
        sortedNamesArray = [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    if ([[sortedNamesArray objectAtIndex:section] isEqualToString:@"Z#"]) {
        return @"#";
    }
    
	
	return [sortedNamesArray objectAtIndex:section];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfRows = 0;
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        numberOfRows = [[self.plantsSearchResultDictionary allKeys] count];
        
    } else {
        numberOfRows = [[self.plantsResultDictionary allKeys] count];
    }
    return numberOfRows;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* sortedNamesArray= nil;
    NSArray* indexKeyArray=nil;
    
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        sortedNamesArray= [[self.plantsSearchResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        indexKeyArray=[self.plantsSearchResultDictionary objectForKey:[sortedNamesArray objectAtIndex:section]];
        
    } else {
        sortedNamesArray= [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        indexKeyArray=[self.plantsResultDictionary objectForKey:[sortedNamesArray objectAtIndex:section]];
    }
    
    return [indexKeyArray count];;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlantCell";
    
    PlantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    
    NSString* sortKeyName=@"";
    
    switch (sortCriteria.integerValue) {
        case FilterByValueFamily:
            //Family
            sortKeyName=@"family";
            
            break;
        case FilterByValueGenus:
            //Genus
            sortKeyName=@"genus";
            
            
            break;
        case FilterByValueClassification:
            //Classification
            sortKeyName=@"classification";
            
            break;
            
        default:
            //Family
            sortKeyName=@"family";

            break;
    }

    
    
    NSNumber *sortOrder = [[NSUserDefaults standardUserDefaults]
                           valueForKey:@"sortOrder"];
    
    BOOL sortOrderAsending=YES;
    
    if (sortOrder==nil)
    {
        sortOrderAsending=YES;
    }
    else
    {
        if (sortOrder.boolValue) {
            sortOrderAsending=YES;        }
        else
        {
            sortOrderAsending=NO;
        }
        
    }

    SpeciesFamily *plant = nil;
    
    NSArray* sortedNamesArray= nil;
    NSMutableArray* indexKeyArray=nil;
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        sortedNamesArray= [[self.plantsSearchResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        indexKeyArray=[[self.plantsSearchResultDictionary objectForKey:[sortedNamesArray objectAtIndex:indexPath.section]] mutableCopy];
        
        //indexKeyArray=[indexKeyArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSSortDescriptor * firstDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKeyName ascending:sortOrderAsending selector:@selector(caseInsensitiveCompare:)];
                                              
        NSArray * descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
        NSArray * sortedArray = [indexKeyArray sortedArrayUsingDescriptors:descriptors];
        
        
        plant=[sortedArray objectAtIndex:indexPath.row];
        
        
    } else {
        sortedNamesArray= [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        indexKeyArray=[[self.plantsResultDictionary objectForKey:[sortedNamesArray objectAtIndex:indexPath.section]] mutableCopy];
        
        NSSortDescriptor * firstDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKeyName ascending:sortOrderAsending selector:@selector(caseInsensitiveCompare:)];
        
        NSArray * descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
        NSArray * sortedArray = [indexKeyArray sortedArrayUsingDescriptors:descriptors];
        
        
        plant=[sortedArray objectAtIndex:indexPath.row];
    }

    [[cell titleLbl] setText:[NSString stringWithFormat:@"%@ %@",plant.genus,plant.species]];
    [[cell familyLbl] setText:[NSString stringWithFormat:@"%@ ",plant.family]];
    [[cell classificationLbl] setText:[NSString stringWithFormat:@"%@ ",plant.classification]];
    
    
    NSString* imageName=[NSString stringWithFormat:@"%@_classification.png", plant.classification];
    [cell.imgView setImage:[UIImage imageNamed:imageName]];
    cell.imgView.contentMode=UIViewContentModeScaleAspectFit;

    
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
    
   

    [self populatePlantsWrapper];
}


-(void)populatePlantsWrapper
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading...";
        hud.tag=6666;
        
        
        AppDelegate* appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.window addSubview:hud];
        [hud showWhileExecuting:@selector(populatePlants) onTarget:self withObject:nil animated:NO];
        
    });
}
    

- (void)hudWasHidden {
    // Remove HUD from screen
    
    // add here the code you may need
    
}

- (IBAction)refreshResults:(id)sender {
    [self populatePlantsWrapper];
}



#pragma mark - UIPickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

//97 height

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
        case FilterByValueClassification:
            pickerValueString=@"Classification";
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
            [self.criteriaSortBtn setTitle:@"Family" forState:UIControlStateNormal];

            break;
        case FilterByValueGenus:
            [self.criteriaSortBtn setTitle:@"Genus" forState:UIControlStateNormal];
            break;
        case FilterByValueClassification:
            [self.criteriaSortBtn setTitle:@"Classification" forState:UIControlStateNormal];
            break;

            
        default:
            break;
    }

    
    [self populatePlantsWrapper];
}


- (void)hideSearchBar {
    
    // scroll search bar out of sight
    CGRect newBounds = self.tableView.bounds;
    if (self.tableView.bounds.origin.y < 44) {
        newBounds.origin.y = newBounds.origin.y + self.searchDisplayController.searchBar.bounds.size.height;
        self.tableView.bounds = newBounds;
    }
    // new for iOS 7
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:0 animated:YES];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.isSearchOn=YES;
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
    self.isSearchOn=NO;
    
    [self.tableView reloadData];
 }

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 97.0f; // or some other height
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

                
            case FilterByValueClassification:
                //Search in Genus
                if ([trimmedsearchString length]>0) {
                    
                    if ([[plant classification] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
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
    
    
    
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    
    self.plantsSearchResultDictionary=[NSMutableDictionary dictionary];
	for (SpeciesFamily *plant in self.plantsSearchResultArray)
	{
        
        NSString *firstLetter =@"";
        
        switch (sortCriteria.integerValue) {
            case FilterByValueFamily:
                //Family
                // get the element's initial letter
                //firstLetter = [plant.family substringToIndex:1];
                firstLetter=plant.family;

                
                break;
            case FilterByValueGenus:
                //Genus
                // get the element's initial letter
                //firstLetter = [plant.genus substringToIndex:1];
                firstLetter=plant.genus;

                
                break;
            case FilterByValueClassification:
                //Classification
                //firstLetter = [plant.classification substringToIndex:1];
                firstLetter=plant.classification;

                break;
                
            default:
                //Family
                
                break;
        }
        
        NSMutableArray *existingArray;
        
        
        if ([Utility isNumeric:firstLetter]) {
            firstLetter=@"Z#";
        }
        
        
        // if an array already exists in the name index dictionary
        // simply add the element to it, otherwise create an array
        // and add it to the name index dictionary with the letter as the key
        if ((existingArray = [self.plantsSearchResultDictionary valueForKey:[firstLetter uppercaseString]]))
        {
            [existingArray addObject:plant];
        } else {
            NSMutableArray *tempArray = [NSMutableArray array];
            [self.plantsSearchResultDictionary setObject:tempArray forKey:[firstLetter uppercaseString]];
            [tempArray addObject:plant];
        }

        

	}

    
    
}




@end
