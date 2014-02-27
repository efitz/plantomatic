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

@interface PlantsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *plantsCountLbl;
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
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.hidesBackButton = YES;
    
    [self populatePlants];
}

-(void) populatePlants
{
    self.plants = [[NSMutableArray alloc] init];
    
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    self.plants = [db getPlantsForY:79 andX:53];
    
    NSLog(@"Plants count = %lu",(unsigned long)self.plants.count);
    
    self.plantsCountLbl.text =[NSString stringWithFormat:@"Total: %lu",(unsigned long)self.plants.count];
    
    [self.tableView reloadData];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.topItem.title = @"Plant-o-matic";
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
    return [self.plants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SpeciesFamily *plant = [self.plants objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ %@",plant.genus,plant.species]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ ",plant.family]];

    
    return cell;
}

- (IBAction)showSortOptions:(id)sender {
    [Utility showAlert:@"" message:@"Under Contstruction..."];
}


- (IBAction)toggleSortOrder:(id)sender {
    [Utility showAlert:@"" message:@"Under Contstruction..."];
}

- (IBAction)refreshResults:(id)sender {
    [Utility showAlert:@"" message:@"Under Contstruction..."];
}

@end
