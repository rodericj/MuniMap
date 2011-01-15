//
//  Route.h
//  MuniMap
//
//  Created by roderic campbell on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Stop;

@interface Route :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * latMax;
@property (nonatomic, retain) NSNumber * lonMin;
@property (nonatomic, retain) NSString * Tag;
@property (nonatomic, retain) NSNumber * latMin;
@property (nonatomic, retain) NSNumber * lonMax;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSSet* routes;

@end


@interface Route (CoreDataGeneratedAccessors)
- (void)addRoutesObject:(Stop *)value;
- (void)removeRoutesObject:(Stop *)value;
- (void)addRoutes:(NSSet *)value;
- (void)removeRoutes:(NSSet *)value;

@end

