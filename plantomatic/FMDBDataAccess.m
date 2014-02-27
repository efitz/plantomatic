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
                 andFilterByValue:(enum FilterByValue)filterByValue
               isInAscendingOrder:(BOOL)isInAscendingOrder
{
    NSMutableArray *SpeciesFamilies = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];
    
    NSMutableString* queryString=[NSMutableString stringWithString:@"SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=? and X=?)"];
    
    switch (filterByValue) {
        case FilterByValueFamily:
            [queryString appendString:@" order by Family"];
            break;
        case FilterByValueGenus:
            [queryString appendString:@" order by Genus"];
            break;
        case FilterByValueSpecies:
            [queryString appendString:@" order by Species"];
            break;
            
        default:
            [queryString appendString:@" order by Family"];
            break;
    }
    
    if (isInAscendingOrder) {
        [queryString appendString:@" asc"];
    }
    else
    {
        [queryString appendString:@" desc"];
    }
    
    
    FMResultSet *results = [db executeQuery:queryString, [NSNumber numberWithInt:y], [NSNumber numberWithInt:x]];
    
    //SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=79 and X=53) order by Family desc

    //FMResultSet *results = [db executeQuery:@"SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=79 and X=53)"];

    
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
