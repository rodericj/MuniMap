//
//  StopDetailViewController.h
//  MuniMap
//
//  Created by roderic campbell on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StopDetailViewController : UITableViewController <NSXMLParserDelegate> {
	int stopId;
	NSMutableData *mIncomingData;
	NSMutableDictionary *mLookup;
	NSString *mCurrentLookup;
}

@property (nonatomic, assign) int stopId;
@property (nonatomic, retain) NSMutableData *incomingData;
@property (nonatomic, retain) NSMutableDictionary *lookup;
@property (nonatomic, retain) NSString *currentLookup;
@end
