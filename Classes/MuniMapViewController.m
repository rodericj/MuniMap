//
//  MuniMapViewController.m
//  MuniMap
//
//  Created by roderic campbell on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MuniMapViewController.h"
#import "StopAnnotation.h"
#import "StopDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#define montgomeryBartLatitude 37.787717
#define montgomeryBartLongitude -122.402458

#define iPhoneWidth  320
#define iPhoneHeight 480
#define bannerHeight  50
#define bannerYStart  480
#define buttonWidth  210
#define buttonHeight  30

@implementation MuniMapViewController

@synthesize locationController = mLocationController;
@synthesize mapView = mMapView;
@synthesize shader = mShader;
@synthesize sfButton = mSFButton;
@synthesize grabber = mGrabber;

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
	
	self.grabber = [[MuniLocationGrabber alloc] init];
	[self.grabber beginLoadingMuniDataWithDelegate:self];
	
	CLLocationCoordinate2D center;
	center.latitude = montgomeryBartLatitude;
	center.longitude = montgomeryBartLongitude;
	
	MKCoordinateRegion m;
	m.span.latitudeDelta = .005;
	m.span.longitudeDelta = .005;
	m.center = center;
	//Set up the span
	[self.mapView setRegion:m animated:YES];

	[self getLocation];
	
	ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
	adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
	adView.delegate = self;
	[self.mapView addSubview:adView];
	

	self.shader = [[UIView alloc] initWithFrame:CGRectMake(0,bannerYStart, iPhoneWidth, bannerHeight)];
	[self.shader setBackgroundColor:[UIColor blackColor]];
	[self.shader setAlpha:0.3];
	
	
	self.sfButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.sfButton setFrame:CGRectMake((iPhoneWidth-buttonWidth)/2, bannerYStart + (bannerHeight-buttonHeight)/2, buttonWidth, buttonHeight)];
	[self.sfButton setTitle:@"Go To San Francisco" forState:UIControlStateNormal];
	[self.sfButton setAlpha:1];
	
	//[shader addSubview:button];
	[self.shader setUserInteractionEnabled:YES];
	[self.sfButton setUserInteractionEnabled:YES];
	[self.mapView addSubview:self.shader];
	[self.mapView addSubview:self.sfButton];

}

-(void)hideShader {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	
	// Slide up based on y axis
	// A better solution over a hard-coded value would be to
	// determine the size of the title and msg labels and 
	// set this value accordingly
	self.shader.frame = CGRectMake(0,bannerYStart, iPhoneWidth, bannerHeight);
	self.sfButton.frame = CGRectMake((iPhoneWidth-buttonWidth)/2, bannerYStart + (bannerHeight-buttonHeight)/2, buttonWidth, buttonHeight);
	[UIView commitAnimations];
	
}

-(void)showShader {
	
	CGRect shaderFrame = self.shader.frame;
	CGRect buttonFrame = self.sfButton.frame;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	
	// Slide up based on y axis
	// A better solution over a hard-coded value would be to
	// determine the size of the title and msg labels and 
	// set this value accordingly
	shaderFrame.origin.y = iPhoneHeight - bannerHeight - 20;
	buttonFrame.origin.y = iPhoneHeight - bannerHeight - 10;
	self.shader.frame = shaderFrame;
	self.sfButton.frame = buttonFrame;
	[UIView commitAnimations];
	
}

-(void)goToSanFrancisco:(UIButton *)pushedButton{
	NSLog(@"go to sf");
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
	[a setStopId:[stopId intValue]];
	
	//control which items are pushed to the map
	
	[self.mapView addAnnotation:a];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	float lat = [mapView centerCoordinate].latitude;
	float lon = [mapView centerCoordinate].longitude;
	NSLog(@"region changed %f, %f", lat, lon);
	if (lat > 37.832650 || lon < -122.538677 || lat < 37.672134 || lon > -122.320747) {

		//Move us to the center of San Francisco
		CLLocationCoordinate2D center;
		center.latitude = montgomeryBartLatitude;
		center.longitude = montgomeryBartLongitude;
		
		MKCoordinateRegion m;
		m.span.latitudeDelta = .005;
		m.span.longitudeDelta = .005;
		m.center = center;
		//Set up the span
		[self.mapView setRegion:m animated:YES];	
	}
	else 
		[self hideShader];
}

-(MKAnnotationView *)buildPinWithAnnotation:(id <MKAnnotation>)annotation
{
	// try to dequeue an existing pin view first
	static NSString* stopannotationidentifier = @"stopAnnotationId";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	[self.mapView dequeueReusableAnnotationViewWithIdentifier:stopannotationidentifier];

	if (!pinView)
	{
		// if an existing pin view was not available, create one
		pinView = [[[MKPinAnnotationView alloc]
											   initWithAnnotation:annotation reuseIdentifier:stopannotationidentifier] autorelease];
		pinView.pinColor = MKPinAnnotationColorGreen;
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
	}
	
	// add a detail disclosure button to the callout which will open a new view controller page
	//
	// note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
	//  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
	//
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightButton addTarget:self
					action:@selector(showDetails:)
		  forControlEvents:UIControlEventTouchUpInside];
	pinView.rightCalloutAccessoryView = rightButton;
	rightButton.tag = [(StopAnnotation*) annotation stopId];

	return pinView;
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	return [self buildPinWithAnnotation:annotation];
}
-(void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];

}
-(void)showDetails:(UIButton *)pushedButton
{
	StopDetailViewController *stopDetailView = [[StopDetailViewController alloc] initWithNibName:@"StopDetailViewController" bundle:nil];
	[stopDetailView setStopId:pushedButton.tag];
	[self.navigationController pushViewController:stopDetailView animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[stopDetailView release];
}

- (void)bannerContainerDidLoadAd:(NSObject *)bannerContainer {
	NSLog(@"did load ad");
}

- (void)bannerContainerActionDidFinish:(NSObject *)bannerContainer {
	NSLog(@"add action did finish");
}

- (void)bannerContainer:(NSObject *)bannerContainer didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"did fail with error %@", error);
}

- (BOOL)bannerContainerActionShouldBegin:(NSObject *)bannerContainer willLeaveApplication:(BOOL)willLeave {
	NSLog(@"Banner view is beginning an ad action");

	return YES;
}

- (void)dealloc
{
    [super dealloc];
	self.locationController = nil;
	self.mapView = nil;
	self.grabber = nil;
}

@end
