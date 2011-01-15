//
//  MuniLocationGrabber.h
//  MuniMap
//
//  Created by roderic campbell on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MuniLocationGrabber : NSObject <NSXMLParserDelegate>{
	NSMutableDictionary *mRoutes;
	NSMutableDictionary *mRawDataDictionary;
	NSString *mCurrentTag;
	NSObject *mDelegate;
}

@property (nonatomic, retain) NSMutableDictionary *routes;
@property (nonatomic, retain) NSMutableDictionary *rawDataDictionary;
@property (nonatomic, retain) NSString	*currentTag;
@property (nonatomic, retain) NSObject *delegate;
-(void)beginLoadingMuniDataWithDelegate:(NSObject *)delegate;

@end
