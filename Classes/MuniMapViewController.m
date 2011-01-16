//
//  MuniMapViewController.m
//  MuniMap
//
//  Created by roderic campbell on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MuniMapViewController.h"
#import "MuniLocationGrabber.h"
#import "StopAnnotation.h"

#define montgomeryBartLatitude 37.787717
#define montgomeryBartLongitude -122.402458

@implementation MuniMapViewController

@synthesize locationController = mLocationController;
@synthesize mapView = mMapView;

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

//Getting the user's location is required when we move geographical location
-(void)getLocation
{
	self.locationController = [[MyCLController alloc] init];
	self.locationController.delegate = self;
	self.locationController.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	[self.locationController.locationManager startUpdatingLocation];
}

- (void)viewDidLoad
{
	[self.view addSubview:self.mapView];
	[self.mapView setShowsUserLocation:YES];
	
	CLLocationCoordinate2D center;
	center.latitude = montgomeryBartLatitude;
	center.longitude = montgomeryBartLongitude;
	
	MuniLocationGrabber *grabber = [[MuniLocationGrabber alloc] init];
	[grabber beginLoadingMuniDataWithDelegate:self];
	[grabber release];
	
	MKCoordinateRegion m;
	m.span.latitudeDelta = .005;
	m.span.longitudeDelta = .005;
	m.center = center;
	//Set up the span
	[self.mapView setRegion:m animated:YES];

	[self getLocation];
}

- (void)locationUpdate:(CLLocation *)location
{
	NSLog(@"location update %@", location);
	CLLocationCoordinate2D center;
	center.latitude = location.coordinate.latitude;
	center.longitude = location.coordinate.longitude;
	
	MKCoordinateRegion m;
	m.span.latitudeDelta = .005;
	m.span.longitudeDelta = .005;
	m.center = center;
	//Set up the span
	[self.mapView setRegion:m animated:YES];
	
}

- (void)locationError:(NSError *)error 
{
	NSLog(@"Error getting location %@", error);
}
	
-(void)pointLoaded:(CLLocationCoordinate2D)center forLine:(NSString *)tag withStopId:(NSString *)stopId
{
	StopAnnotation *a = [[StopAnnotation alloc] initWithCoordinate:center];
	[a setTitle:tag];	
	
	[self.mapView addAnnotation:a];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	NSLog(@"region changed %f, %f", [mapView centerCoordinate].latitude, [mapView centerCoordinate].longitude);
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		NSLog(@"this is the user location");
	return nil;
}

- (void)dealloc
{
    [super dealloc];
	self.locationController = nil;
	self.mapView = nil;
}

@end
