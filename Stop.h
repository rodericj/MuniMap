//
//  Stop.h
//  MuniMap
//
//  Created by roderic campbell on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Route;

@interface Stop :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSString * stopId;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) Route * newRelationship;

@end



