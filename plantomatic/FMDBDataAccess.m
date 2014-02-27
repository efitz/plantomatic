//
//  FMDBDataAccess.m
//  plantomatic
//
//  Created by developer on 2/27/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import "FMDBDataAccess.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "Utility.h"
#import "SpeciesFamily.h"

@implementation FMDBDataAccess

-(NSMutableArray *) getPlantsForY:(int)y
                             andX:(int)x
{
    NSMutableArray *SpeciesFamilies = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];
    
    
    
    //FMResultSet *results = [db executeQuery:@"SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=? and X=?)", [NSNumber numberWithInt:y], [NSNumber numberWithInt:x]];
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=79 and X=53)"];

    
    while([results next])
    {
        SpeciesFamily *speciesFamily = [[SpeciesFamily alloc] init];
        
        speciesFamily.spID = [results intForColumn:@"SpID"];
        speciesFamily.family = [results stringForColumn:@"Family"];
        speciesFamily.genus = [results stringForColumn:@"Genus"];
        speciesFamily.species = [results stringForColumn:@"Species"];
        
        [SpeciesFamilies addObject:speciesFamily];
        
    }
    
    [db close];
    
    return SpeciesFamilies;
}


@end
