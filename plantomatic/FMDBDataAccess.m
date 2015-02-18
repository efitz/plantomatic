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
        case FilterByValueClassification:
            [queryString appendString:@" order by Classification"];
            break;
        case FilterByValueHabit:
            [queryString appendString:@" order by Habit"];
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

    
    /*
     replace into SpeciesFamily
     (SpID,  Classification)
     (select SpeciesFamily.SpID, Classification.Classification
     from Classification
     inner join SpeciesFamily on SpeciesFamily.Family = Classification.Family)
     
     
     
     replace into SpeciesFamily
     (SpID, Family, Genus, Species, Classification)
     select SpeciesFamily.SpID, SpeciesFamily.Family, SpeciesFamily.Genus, SpeciesFamily.Species, Classification.Classification
     from Classification
     inner join SpeciesFamily on SpeciesFamily.Family = Classification.Family
     
     
     Update SpeciesFamily Set
     Classification = (select Classification.Classification
     from Classification
     inner join SpeciesFamily on SpeciesFamily.Family = Classification.Family)
     */
    
    
    while([results next])
    {
        SpeciesFamily *speciesFamily = [[SpeciesFamily alloc] init];
        
        speciesFamily.spID = [results intForColumn:@"SpID"];
        speciesFamily.family = [results stringForColumn:@"Family"];
        speciesFamily.genus = [results stringForColumn:@"Genus"];
        speciesFamily.species = [results stringForColumn:@"Species"];
        speciesFamily.classification = [results stringForColumn:@"Classification"];
        speciesFamily.habit = [results stringForColumn:@"Habit"];
        speciesFamily.isImageAvailabe = [results stringForColumn:@"isImageAvailabe"];
        speciesFamily.commonName=[results stringForColumn:@"Common_Name"];
        speciesFamily.flowerColor=[results stringForColumn:@"Flower_Color"];

        [SpeciesFamilies addObject:speciesFamily];
        
    }
    
    [db close];
    
    return SpeciesFamilies;
}






-(NSMutableArray *) getPlantsWithFilterForY:(int)y
                                       andX:(int)x
{
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    BOOL isInAscendingOrder=(int)sortCriteria.integerValue;
    
    NSMutableDictionary* growthFormDictionary= [[NSUserDefaults standardUserDefaults] objectForKey:@"growthFormDictionary"];
    NSArray* growthFormKeys=[growthFormDictionary allKeys];
    NSMutableArray* growthFromArray=[NSMutableArray array];
    
    for (NSString* key in growthFormKeys) {
        
        NSDictionary* dictionary=[growthFormDictionary valueForKey:key];
        NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
        
        if (isSelected.boolValue)
        {
            if ([key isEqualToString:@"Unknown"]) {
                NSString* value=[NSString stringWithFormat:@"Habit=\'%@\'",@"-"];
                [growthFromArray addObject:value];
            }
            else
            {
                NSString* value=[NSString stringWithFormat:@"Habit=\'%@\'",key];
                [growthFromArray addObject:value];
            }
        }
    }

    NSString *growthFormQuery = [growthFromArray componentsJoinedByString:@" or "];

    
    
    NSMutableDictionary* flowerColorsDictionary=[[NSUserDefaults standardUserDefaults] objectForKey:@"flowerColorsDictionary"];
    NSArray* flowerColorsKeys=[flowerColorsDictionary allKeys];
    NSMutableArray* flowerColorsArray=[NSMutableArray array];
    
    for (NSString* key in flowerColorsKeys) {
        
        NSDictionary* dictionary=[flowerColorsDictionary valueForKey:key];
        NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
        
        if (isSelected.boolValue)
        {
            if ([key isEqualToString:@"Unknown-Flower"]) {
                NSString* value=[NSString stringWithFormat:@"Flower_Color=\'%@\'",@"-"];
                [flowerColorsArray addObject:value];
            }
            else
            {
                NSString* value=[NSString stringWithFormat:@"Flower_Color=\'%@\'",key];
                [flowerColorsArray addObject:value];
            }

        }
    }
    
    NSString *flowerColorsQuery = [flowerColorsArray componentsJoinedByString:@" or "];
    
    NSMutableArray* familiesSelected=[[NSUserDefaults standardUserDefaults] objectForKey:@"familiesSelected"];
    
    NSMutableArray* familiesArray=[NSMutableArray array];
    for (NSString* family in familiesSelected)
    {
        NSString* value=[NSString stringWithFormat:@"family=\'%@\'",family];
        [familiesArray addObject:value];
    }
    
    NSString* familyQueryString=[familiesArray componentsJoinedByString:@" or "];
    
    
    
    
    NSNumber *isCommonNameAvaialble = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:@"isCommonNameAvailable"];
    
    NSNumber *isImageAvailable = [[NSUserDefaults standardUserDefaults]
                                  valueForKey:@"isImageAvailable"];

    
    
    NSMutableArray *SpeciesFamilies = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];
    
    NSMutableString* queryString=[NSMutableString stringWithString:@"SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=? and X=?)"];
    
    
    if (isCommonNameAvaialble.boolValue) {
        [queryString appendString:@" and Common_Name!=\'-\'"];
    }
    else
    {
        [queryString appendString:@" and Common_Name=\'-\'"];
    }
    
    if (isImageAvailable.boolValue) {
        [queryString appendString:@" and isImageAvailabe=\'TRUE\'"];
    }
    else
    {
//        [queryString appendString:@" and isImageAvailabe=\'FALSE\'"];
    }
    
    
    if ([growthFromArray count]>0) {
        [queryString appendString:@" and ("];
        [queryString appendString:growthFormQuery];
        [queryString appendString:@")"];
    }
    
    if ([flowerColorsArray count]>0) {
        [queryString appendString:@" and ("];
        [queryString appendString:flowerColorsQuery];
        [queryString appendString:@")"];
    }

    if ([familiesArray count]>0) {
        [queryString appendString:@" and ("];
        [queryString appendString:familyQueryString];
        [queryString appendString:@")"];
    }
    
//    if (isInAscendingOrder) {
//        [queryString appendString:@" asc"];
//    }
//    else
//    {
//        [queryString appendString:@" desc"];
//    }
    
    
    FMResultSet *results = [db executeQuery:queryString, [NSNumber numberWithInt:y], [NSNumber numberWithInt:x]];
    
    //SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=79 and X=53) order by Family desc
    
    //FMResultSet *results = [db executeQuery:@"SELECT * FROM SpeciesFamily where SpId in (select SpId from Presence where Y=79 and X=53)"];
    
    
    /*
     replace into SpeciesFamily
     (SpID,  Classification)
     (select SpeciesFamily.SpID, Classification.Classification
     from Classification
     inner join SpeciesFamily on SpeciesFamily.Family = Classification.Family)
     
     
     
     replace into SpeciesFamily
     (SpID, Family, Genus, Species, Classification)
     select SpeciesFamily.SpID, SpeciesFamily.Family, SpeciesFamily.Genus, SpeciesFamily.Species, Classification.Classification
     from Classification
     inner join SpeciesFamily on SpeciesFamily.Family = Classification.Family
     
     
     Update SpeciesFamily Set
     Classification = (select Classification.Classification
     from Classification
     inner join SpeciesFamily on SpeciesFamily.Family = Classification.Family)
     */
    
    
    while([results next])
    {
        SpeciesFamily *speciesFamily = [[SpeciesFamily alloc] init];
        
        speciesFamily.spID = [results intForColumn:@"SpID"];
        speciesFamily.family = [results stringForColumn:@"Family"];
        speciesFamily.genus = [results stringForColumn:@"Genus"];
        speciesFamily.species = [results stringForColumn:@"Species"];
        speciesFamily.classification = [results stringForColumn:@"Classification"];
        speciesFamily.habit = [results stringForColumn:@"Habit"];
        speciesFamily.isImageAvailabe = [results stringForColumn:@"isImageAvailabe"];
        speciesFamily.commonName=[results stringForColumn:@"Common_Name"];
        speciesFamily.flowerColor=[results stringForColumn:@"Flower_Color"];
        
        [SpeciesFamilies addObject:speciesFamily];
        
    }
    
    [db close];
    
    return SpeciesFamilies;
}


-(NSMutableArray *) getFamiliesWithFilterForY:(int)y
                                         andX:(int)x
{
    NSNumber *sortCriteria = [[NSUserDefaults standardUserDefaults]
                              valueForKey:@"sortCriteria"];
    BOOL isInAscendingOrder=(int)sortCriteria.integerValue;
    
    NSMutableDictionary* growthFormDictionary= [[NSUserDefaults standardUserDefaults] objectForKey:@"growthFormDictionary"];
    NSArray* growthFormKeys=[growthFormDictionary allKeys];
    NSMutableArray* growthFromArray=[NSMutableArray array];
    
    for (NSString* key in growthFormKeys) {
        
        NSDictionary* dictionary=[growthFormDictionary valueForKey:key];
        NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
        
        if (isSelected.boolValue)
        {
            if ([key isEqualToString:@"Unknown"]) {
                NSString* value=[NSString stringWithFormat:@"Habit=\'%@\'",@"-"];
                [growthFromArray addObject:value];
            }
            else
            {
                NSString* value=[NSString stringWithFormat:@"Habit=\'%@\'",key];
                [growthFromArray addObject:value];
            }
        }
    }
    
    NSString *growthFormQuery = [growthFromArray componentsJoinedByString:@" or "];
    
    
    
    NSMutableDictionary* flowerColorsDictionary=[[NSUserDefaults standardUserDefaults] objectForKey:@"flowerColorsDictionary"];
    NSArray* flowerColorsKeys=[flowerColorsDictionary allKeys];
    NSMutableArray* flowerColorsArray=[NSMutableArray array];
    
    for (NSString* key in flowerColorsKeys) {
        
        NSDictionary* dictionary=[flowerColorsDictionary valueForKey:key];
        NSNumber* isSelected=[dictionary valueForKey:@"isSelected"];
        
        if (isSelected.boolValue)
        {
            if ([key isEqualToString:@"Unknown-Flower"]) {
                NSString* value=[NSString stringWithFormat:@"Flower_Color=\'%@\'",@"-"];
                [flowerColorsArray addObject:value];
            }
            else
            {
                NSString* value=[NSString stringWithFormat:@"Flower_Color=\'%@\'",key];
                [flowerColorsArray addObject:value];
            }
            
        }
    }
    
    NSString *flowerColorsQuery = [flowerColorsArray componentsJoinedByString:@" or "];
    
    
    NSNumber *isCommonNameAvaialble = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:@"isCommonNameAvailable"];
    
    NSNumber *isImageAvailable = [[NSUserDefaults standardUserDefaults]
                                  valueForKey:@"isImageAvailable"];
    
    
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:[Utility getDatabasePath]];
    
    [db open];
    
    NSMutableString* queryString=[NSMutableString stringWithString:@"SELECT distinct family FROM SpeciesFamily where SpId in (select SpId from Presence where Y=? and X=?)"];
    
    
    if (isCommonNameAvaialble.boolValue) {
        [queryString appendString:@" and Common_Name!=\'-\'"];
    }
    else
    {
        [queryString appendString:@" and Common_Name=\'-\'"];
    }
    
    if (isImageAvailable.boolValue) {
        [queryString appendString:@" and isImageAvailabe=\'TRUE\'"];
    }
    else
    {
        [queryString appendString:@" and isImageAvailabe=\'FALSE\'"];
    }
    
    
    if ([growthFromArray count]>0) {
        [queryString appendString:@" and ("];
        [queryString appendString:growthFormQuery];
        [queryString appendString:@")"];
    }
    
    if ([flowerColorsArray count]>0) {
        [queryString appendString:@" and ("];
        [queryString appendString:flowerColorsQuery];
        [queryString appendString:@")"];
    }
    
    
    [queryString appendString:@" order by Family asc"];
    
    
    FMResultSet *results = [db executeQuery:queryString, [NSNumber numberWithInt:y], [NSNumber numberWithInt:x]];
    
    
    NSMutableArray *SpeciesFamilies = [NSMutableArray array];

    while([results next])
    {
       [SpeciesFamilies addObject:[results stringForColumn:@"Family"]];
    }
    
    [db close];
    
    return SpeciesFamilies;
}


@end
