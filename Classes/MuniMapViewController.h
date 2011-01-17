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

@interface MuniMapViewController : UIViewController <MyCLControllerDelegate, MKMapViewDelegate, ADBannerViewDelegate>{
	MyCLController *mLocationController;
	MKMapView *mMapView;
}

@property (nonatomic, retain)			MyCLController *locationController;
@property (nonatomic, retain) IBOutlet	MKMapView *mapView;

-(void)pointLoaded:(CLLocationCoordinate2D)center forLine:(NSString *)tag withStopId:(NSString *)stopId;
-(void)getLocation;

@end

