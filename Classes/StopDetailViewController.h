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
@property (nonatomic, assign) NSMutableData *incomingData;
@property (nonatomic, assign) NSMutableDictionary *lookup;
@property (nonatomic, assign) NSString *currentLookup;
@end
