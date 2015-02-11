//
//  PlantCell.h
//  plantomatic
//
//  Created by developer on 3/7/14.
//  Copyright (c) 2014 Ocotea Technologies, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpeciesFamily;

@interface PlantCell : UITableViewCell

-(void) updateWithSpeciesFamily:(SpeciesFamily*)speciesFamily;

@end
