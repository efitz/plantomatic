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
#import "Constants.h"   
#include "proj_api.h"
#import "PlantCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PlantImagesService.h"
#import "PlantImagesList.h"
#import "PlantsCollectionViewController.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@interface PlantsViewController ()<PlantImagesServiceDelegate,UIActionSheetDelegate>

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

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, readwrite) BOOL isSearchOn;

@property (strong, nonatomic) IBOutlet UIView *searchView;

@property (strong, nonatomic) PlantImagesService *plantImagesService;


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
    if([Utility isiOS7])
        self.edgesForExtendedLayout = UIRectEdgeNone;

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
    
    /*
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
                [self.criteriaSortBtn setTitle:@"Major Group" forState:UIControlStateNormal];
                break;
            case FilterByValueHabit:
                [self.criteriaSortBtn setTitle:@"Habit" forState:UIControlStateNormal];
                break;

                
            default:
                break;
        }
    }

    self.pickerViewSelectedIndex=(int)sortCriteria.integerValue;
*/
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:168/255.0 green:204/255.0 blue:251/255.0 alpha:1]];
    
    [self populatePlantsWrapper];
    
    [self hidePicker];
    
    
    PlantImagesService *plantImagesService = [[PlantImagesService alloc] initServiceWithDelegate:self];
    self.plantImagesService = plantImagesService;

    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(refreshResults:) name:REFRESH_NOTIFICATION object:nil];

    
    //sortOrderBtn
    CALayer *btnLayer = [self.criteriaSortBtn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    btnLayer.borderWidth=1;
    btnLayer.borderColor=[[UIColor whiteColor] CGColor];
    
    
    btnLayer =[self.searchView layer];
    [btnLayer setMasksToBounds:YES];
    btnLayer.borderWidth=1;
    btnLayer.borderColor=[[UIColor blackColor] CGColor];

    
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

    
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    
    //self.plants = [db getPlantsForY:lat andX:lon andFilterByValue:sortCriteria.integerValue isInAscendingOrder:sortOrder.boolValue];

	//if outside of the US set the grid to Tuscon, AZ
	if (-1*lon1 > 170 || -1*lon1 < 58) {
		Y=50;
		X=24;
	}

//    Y=60;
//    X=53;
    
//    self.plants = [db getPlantsForY:Y andX:X andFilterByValue:(int)sortCriteria.integerValue isInAscendingOrder:sortOrder.boolValue]; //Hardcoded to match Arizona

    //getPlantsWithFilterForY
     self.plants = [db getPlantsWithFilterForY:Y andX:X];
    
    pj_free(src_prj);
    pj_free(dst_prj);

    NSLog(@"Plants count = %lu",(unsigned long)self.plants.count);
    
    self.plantsResultDictionary=[NSMutableDictionary dictionary];

    // iterate over the values in the raw elements dictionary
	for (SpeciesFamily *plant in self.plants)
	{
        
        NSString *firstLetter =[plant.family substringToIndex:1];
        
        
        NSMutableArray* sortColumnsSelected=[[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"] mutableCopy];

        if ([sortColumnsSelected count]==0) {
            //by default sort by family
        }
        else
        {
            NSString* sortColumn=[sortColumnsSelected objectAtIndex:0u];
            
            //@[@"Family",@"Genus",@"Species", @"Habit", @"Flower_Color", @"Common_Name"]
            
            if ([sortColumn isEqualToString:@"Family"])
            {
                firstLetter = [plant.family substringToIndex:1];

            }
            else if([sortColumn isEqualToString:@"Genus"])
            {
                firstLetter = [plant.genus substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Species"])
            {
                firstLetter = [plant.species substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Habit"])
            {
                firstLetter = [plant.habit substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Flower_Color"])
            {
                firstLetter = [plant.flowerColor substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Common_Name"])
            {
                firstLetter = [plant.commonName substringToIndex:1];
            }
        }
        
        
        
        /*
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
            case FilterByValueHabit:
                //Classification
                firstLetter = [plant.habit substringToIndex:1];
                
                
                break;
                
            default:
                //Family
                
                break;
        }
*/
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

    self.plantsCountLbl.text =[NSString stringWithFormat:@"Total: %lu species",(unsigned long)self.plants.count];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    
    //To make sure the use sees the loading indicator where query taken very short time
    NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 1.0 ];
    [NSThread sleepUntilDate:future];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.topItem.title = @"Plant-O-Matic";
    //Google Analytics page view
    self.screenName = @"Results View";
    
    
    if ([self.searchDisplayController.searchBar.text length] == 0 && self.isSearchOn==NO)
    {
        self.plantsSearchResultArray = [NSMutableArray array];
        self.plantsSearchResultDictionary = [NSMutableDictionary dictionary];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark UITableViewDataSource Method

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    // returns the array of section titles. There is one entry for each unique character that an element begins with
    // [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
    
    NSArray* sortedNamesArray=nil;
    
    if (!self.isSearchOn) {
        sortedNamesArray= [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSNumber *isSortOrderAscending = [[NSUserDefaults standardUserDefaults]
                                          valueForKey:@"sortOrder"];

        if (isSortOrderAscending.boolValue==NO)
        {
            //descending order
            sortedNamesArray=[sortedNamesArray reversedArray];
        }
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
    
    NSNumber *isSortOrderAscending = [[NSUserDefaults standardUserDefaults]
                                      valueForKey:@"sortOrder"];

    
    
    NSArray* sortedNamesArray = nil;
    if(self.isSearchOn){
        sortedNamesArray = [[self.plantsSearchResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

//        if (isSortOrderAscending.boolValue==NO)
//        {
//            //descending order
//            sortedNamesArray=[sortedNamesArray reversedArray];
//        }

        
    } else {
        sortedNamesArray = [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        if (isSortOrderAscending.boolValue==NO)
        {
            //descending order
            sortedNamesArray=[sortedNamesArray reversedArray];
        }
    }
    
    if ([[sortedNamesArray objectAtIndex:section] isEqualToString:@"Z#"]) {
        return @"#";
    }
    
	
	return [sortedNamesArray objectAtIndex:section];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfRows = 0;
    if(self.isSearchOn){
        numberOfRows = [[self.plantsSearchResultDictionary allKeys] count];
        
    } else {
        numberOfRows = [[self.plantsResultDictionary allKeys] count];
    }
    return numberOfRows;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* sortedNamesArray= nil;
    NSArray* indexKeyArray=nil;
    
    NSNumber *isSortOrderAscending = [[NSUserDefaults standardUserDefaults]
                                      valueForKey:@"sortOrder"];
    
    
    if(self.isSearchOn){
        sortedNamesArray= [[self.plantsSearchResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
//        if (isSortOrderAscending.boolValue==NO)
//        {
//            //descending order
//            sortedNamesArray=[sortedNamesArray reversedArray];
//        }
  
        
        indexKeyArray=[self.plantsSearchResultDictionary objectForKey:[sortedNamesArray objectAtIndex:section]];
        
    } else {
        sortedNamesArray= [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        
        if (isSortOrderAscending.boolValue==NO)
        {
            //descending order
            sortedNamesArray=[sortedNamesArray reversedArray];
        }

        
        indexKeyArray=[self.plantsResultDictionary objectForKey:[sortedNamesArray objectAtIndex:section]];
    }
    
    return [indexKeyArray count];;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlantCell";
    
    PlantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    SpeciesFamily *plant = [self getPlantForIndexPath:indexPath];
    [cell updateWithSpeciesFamily:plant];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpeciesFamily *plant = [self getPlantForIndexPath:indexPath];

    if ([plant.isImageAvailabe isEqualToString:@"TRUE"]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.plantImagesService fetchPlantImagesListForGenus:plant.genus species:plant.species];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


-(SpeciesFamily*)getPlantForIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    
    NSString* sortKeyName=@"family";
    
    NSMutableArray* sortColumnsSelected=[[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"] mutableCopy];

    
    if ([sortColumnsSelected count]==0) {
        //by default sort by family
    }
    else
    {
        NSString* sortColumn=[sortColumnsSelected objectAtIndex:0u];
        
        //@[@"Family",@"Genus",@"Species", @"Habit", @"Flower_Color", @"Common_Name"]
        
        if ([sortColumn isEqualToString:@"Family"])
        {
            sortKeyName = @"family";
            
        }
        else if([sortColumn isEqualToString:@"Genus"])
        {
            sortKeyName = @"genus";
        }
        else if([sortColumn isEqualToString:@"Species"])
        {
            sortKeyName = @"species";
        }
        else if([sortColumn isEqualToString:@"Habit"])
        {
            sortKeyName = @"habit";
        }
        else if([sortColumn isEqualToString:@"Flower_Color"])
        {
            sortKeyName = @"flowerColor";
        }
        else if([sortColumn isEqualToString:@"Common_Name"])
        {
            sortKeyName = @"commonName";
        }
    }
    

    
    
    /*
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
        case FilterByValueHabit:
            //Classification
            sortKeyName=@"habit";
            
            break;
            
        default:
            //Family
            sortKeyName=@"family";
            
            break;
    }
    */
    
    
    NSNumber *sortOrder = [[NSUserDefaults standardUserDefaults]
                           valueForKey:@"sortOrder"];
    
    BOOL sortOrderAsending=YES;
    
    if (sortOrder==nil)
    {
        sortOrderAsending=YES;
    }
    else
    {
        if (sortOrder.boolValue)
        {
            sortOrderAsending=YES;
        }
        else
        {
            sortOrderAsending=NO;
        }
        
    }
    
    SpeciesFamily *plant = nil;
    
    NSArray* sortedNamesArray= nil;
    NSMutableArray* indexKeyArray=nil;
    if(self.isSearchOn){
        sortedNamesArray= [[self.plantsSearchResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
//        if (sortOrder.boolValue==NO) {
//            sortedNamesArray=[sortedNamesArray reversedArray];
//        }
        
        indexKeyArray=[[self.plantsSearchResultDictionary objectForKey:[sortedNamesArray objectAtIndex:indexPath.section]] mutableCopy];
        
        //indexKeyArray=[indexKeyArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSSortDescriptor * firstDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKeyName ascending:sortOrderAsending selector:@selector(caseInsensitiveCompare:)];
        
        NSArray * descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
        NSArray * sortedArray = [indexKeyArray sortedArrayUsingDescriptors:descriptors];
        
        
        plant=[sortedArray objectAtIndex:indexPath.row];
        
        
    } else {
        sortedNamesArray= [[self.plantsResultDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        if (sortOrder.boolValue==NO) {
            sortedNamesArray=[sortedNamesArray reversedArray];
        }
        
        indexKeyArray=[[self.plantsResultDictionary objectForKey:[sortedNamesArray objectAtIndex:indexPath.section]] mutableCopy];
        
        NSSortDescriptor * firstDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKeyName ascending:sortOrderAsending selector:@selector(caseInsensitiveCompare:)];
        
        NSArray * descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
        NSArray * sortedArray = [indexKeyArray sortedArrayUsingDescriptors:descriptors];
        
        
        plant=[sortedArray objectAtIndex:indexPath.row];
    }

    return plant;
}




- (IBAction)showSortOptions:(id)sender {
   
    //[self showPicker];
    
    UIActionSheet* actionSheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Family",@"Genus",@"Major Group",@"Habit", nil];
	actionSheet.title = @"Sort by:";
    [actionSheet showInView:self.view];
    
    //[Utility showAlert:@"" message:@"Under Contstruction..."];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",(int)buttonIndex);
    
    if (buttonIndex==4) {
        return;
    }
    else
    {
        /*
        self.pickerViewSelectedIndex =(int)buttonIndex;
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
                [self.criteriaSortBtn setTitle:@"Major Group" forState:UIControlStateNormal];
                break;
            case FilterByValueHabit:
                [self.criteriaSortBtn setTitle:@"Habit" forState:UIControlStateNormal];
                break;
                
                
            default:
                break;
        }*/
        
        self.searchBar.text=@"";
        self.isSearchOn=NO;    
        [self populatePlantsWrapper];
    }
 

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
    return 4;
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
            pickerValueString=@"Major Group";
            break;
        case FilterByValueHabit:
            pickerValueString=@"Habit";
            break;
            
        default:
            pickerValueString=@"Family";
            break;
    }
    
    return pickerValueString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickerViewSelectedIndex = (int)row;
}

- (IBAction)hidePickerAction:(id)sender {
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    self.pickerViewSelectedIndex =(int)sortCriteria.integerValue;
    
    [self hidePicker];
}

- (IBAction)doneAction:(id)sender {
    [self hidePicker];
    
    /*
    self.pickerViewSelectedIndex=(int)[self.pickerView selectedRowInComponent:0];
    
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
            [self.criteriaSortBtn setTitle:@"Major Group" forState:UIControlStateNormal];
            break;
        case FilterByValueHabit:
            [self.criteriaSortBtn setTitle:@"Habit" forState:UIControlStateNormal];
            break;

            
        default:
            break;
    }*/

    self.searchBar.text=@"";
    self.isSearchOn=NO;    
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    tableView.rowHeight = 130.0f; // or some other height
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
        /*
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
                
            case FilterByValueHabit:
                //Search in Genus
                if ([trimmedsearchString length]>0) {
                    
                    if ([[plant habit] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        //add plant
                        [self.plantsSearchResultArray addObject:plant];
                    }
                }
                break;


                
                
            default:
                break;
        }*/
        
        
        
        if ([trimmedsearchString length]>0) {
            
            if ([[plant family] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //add plant
                [self.plantsSearchResultArray addObject:plant];
            }
            else if ([[plant genus] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //add plant
                [self.plantsSearchResultArray addObject:plant];
            }
            else if ([[plant classification] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //add plant
                [self.plantsSearchResultArray addObject:plant];
            }
            else if ([[plant species] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //add plant
                [self.plantsSearchResultArray addObject:plant];
            }
            else if ([[plant habit] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //add plant
                [self.plantsSearchResultArray addObject:plant];
            }
            else if ([[plant flowerColor] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //add plant
                [self.plantsSearchResultArray addObject:plant];
            }
            else if ([[plant commonName] rangeOfString:trimmedsearchString options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //add plant
                [self.plantsSearchResultArray addObject:plant];
            }

        }
    }
    
    
    
    
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    
    
    self.plantsSearchResultDictionary=[NSMutableDictionary dictionary];
	for (SpeciesFamily *plant in self.plantsSearchResultArray)
	{
        
        NSString *firstLetter =[plant.family substringToIndex:1];
        
//        switch (sortCriteria.integerValue) {
//            case FilterByValueFamily:
//                //Family
//                // get the element's initial letter
//                firstLetter = [plant.family substringToIndex:1];
//
//                
//                break;
//            case FilterByValueGenus:
//                //Genus
//                // get the element's initial letter
//                firstLetter = [plant.genus substringToIndex:1];
//                
//                
//                break;
//            case FilterByValueClassification:
//                //Classification
//                firstLetter = [plant.classification substringToIndex:1];
//                
//                break;
//            case FilterByValueHabit:
//                //Classification
//                firstLetter = [plant.habit substringToIndex:1];
//                
//                break;
//                
//            default:
//                //Family
//                
//                break;
//        }
        
        
        NSMutableArray* sortColumnsSelected=[[[NSUserDefaults standardUserDefaults] objectForKey:@"sortColumns"] mutableCopy];
        
        if ([sortColumnsSelected count]==0) {
            //by default sort by family
        }
        else
        {
            NSString* sortColumn=[sortColumnsSelected objectAtIndex:0u];
            
            //@[@"Family",@"Genus",@"Species", @"Habit", @"Flower_Color", @"Common_Name"]
            
            if ([sortColumn isEqualToString:@"Family"])
            {
                firstLetter = [plant.family substringToIndex:1];
                
            }
            else if([sortColumn isEqualToString:@"Genus"])
            {
                firstLetter = [plant.genus substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Species"])
            {
                firstLetter = [plant.species substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Habit"])
            {
                firstLetter = [plant.habit substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Flower_Color"])
            {
                firstLetter = [plant.flowerColor substringToIndex:1];
            }
            else if([sortColumn isEqualToString:@"Common_Name"])
            {
                firstLetter = [plant.commonName substringToIndex:1];
            }
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

/*

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                     // called when text starts editing
{
    self.isSearchOn=YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self handleSearchForTerm:searchBar.text];
    [self.tableView reloadData];

}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
// called when keyboard search button pressed
{
    [self handleSearchForTerm:searchBar.text];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    self.isSearchOn=NO;

}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    
}
*/

- (void)handleSearch:(NSString *)searchText {
    NSString *trimmedsearchString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedsearchString.length==0) {
        self.isSearchOn=NO;
        [self.tableView reloadData];
        
        self.plantsCountLbl.text =[NSString stringWithFormat:@"Total: %lu species",(unsigned long)self.plants.count];
    }
    else
    {
        self.isSearchOn=YES;
        [self handleSearchForTerm:searchText];
        [self.tableView reloadData];
        
        self.plantsCountLbl.text =[NSString stringWithFormat:@"Total: %lu species",(unsigned long)self.plantsSearchResultArray.count];
    }

}

#pragma mark -
#pragma mark UISearchBarDelegate Method

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self handleSearch:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar.text];
     [searchBar resignFirstResponder];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self handleSearch:searchBar.text];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    self.isSearchOn=NO;
    [self.tableView reloadData];
    searchBar.text=@"";
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    
    self.plantsCountLbl.text =[NSString stringWithFormat:@"Total: %lu  species",(unsigned long)self.plants.count];

}

#pragma mark -
#pragma mark PlantImagesServiceDelegate Method

- (void)plantImagesFetchSucceed:(PlantImagesList *)plantImagesList
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    //NSString* message=[NSString stringWithFormat:@"Images found for selected plant = %lu",(unsigned long)plantImagesList.plantImages.count];
    //[Utility showAlert:@"PlantOMatic Test Alert" message:message];
    
    //PlantsCollectionViewController* plantsCollectionViewController=[[PlantsCollectionViewController alloc] int
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlantsCollectionViewController *plantsCollectionViewController = (PlantsCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlantsCollectionViewController"];
    
    plantsCollectionViewController.assets=plantImagesList.plantImages;
    
    [self.navigationController pushViewController:plantsCollectionViewController animated:YES];
}

- (void)plantImagesFetchFailed:(NSString *)errorMessage
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if ([errorMessage isEqualToString:@"No records were found"]) {
        errorMessage=@"No images available.";//@"No images available on Tropicos for this record";
    }
    
    NSString* alertTitle=@"";
    
    if ([errorMessage isEqualToString:NO_INTERNET_MSG]) {
        alertTitle=@"Plant-O-Matic Error";
    }
    else
    {
        alertTitle=@"Tropicos Error";
    }
    

    [Utility showAlert:alertTitle message:errorMessage];

}


@end
