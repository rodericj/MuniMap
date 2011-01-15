//
//  BTVenueAnnotation.m
//  Traps
//
//  Created by Roderic Campbell on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopAnnotation.h"


@implementation StopAnnotation
@synthesize coordinate;
@synthesize title;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
