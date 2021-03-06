//
//  MuniLocationGrabber.h
//  MuniMap
//
//  Created by roderic campbell on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MuniMapViewController.h"
@interface MuniLocationGrabber : NSObject <NSXMLParserDelegate>{
	NSMutableDictionary *mRoutes;
	NSMutableDictionary *mRawDataDictionary;
	NSString *mCurrentTag;
	id mDelegate;
}

@property (nonatomic, retain) NSMutableDictionary *routes;
@property (nonatomic, retain) NSMutableDictionary *rawDataDictionary;
@property (nonatomic, retain) NSString	*currentTag;
@property (nonatomic, retain) id delegate;

-(void)beginLoadingMuniDataWithDelegate:(id)delegate;

@end
