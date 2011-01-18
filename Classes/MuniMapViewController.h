//
//  MuniMapViewController.h
//  MuniMap
//
//  Created by roderic campbell on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"
#import <MapKit/MapKit.h>
#import <iAd/iAd.h>
#import "MuniLocationGrabber.h"

@interface MuniMapViewController : UIViewController <MyCLControllerDelegate, MKMapViewDelegate, ADBannerViewDelegate>{
	MyCLController *mLocationController;
	MKMapView *mMapView;
	UIView *mShader;
	UIButton *MSFButton;
	MuniLocationGrabber *mGrabber;
}

@property (nonatomic, retain)			MyCLController *locationController;
@property (nonatomic, retain) IBOutlet	MKMapView *mapView;
@property (nonatomic, retain)			UIView *shader;
@property (nonatomic, retain)			UIButton *sfButton;
@property (nonatomic, retain)			MuniLocationGrabber *grabber;

-(void)pointLoaded:(CLLocationCoordinate2D)center forLine:(NSString *)tag withStopId:(NSString *)stopId;
-(void)getLocation;

@end

