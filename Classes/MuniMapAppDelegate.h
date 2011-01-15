//
//  MuniMapAppDelegate.h
//  MuniMap
//
//  Created by roderic campbell on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MuniMapViewController;

@interface MuniMapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MuniMapViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MuniMapViewController *viewController;


@end

