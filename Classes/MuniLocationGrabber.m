//
//  MuniLocationGrabber.m
//  MuniMap
//
//  Created by roderic campbell on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MuniLocationGrabber.h"
#import <CoreData/CoreData.h>
#import "MuniMapAppDelegate.h"
#import "MuniMapViewController.h"

#define muniRoutlistUrl @"http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni"
#define routeDetailURL @"http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r="

@implementation MuniLocationGrabber

@synthesize routes = mRoutes;
@synthesize rawDataDictionary = mRawDataDictionary;
@synthesize currentTag = mCurrentTag;
@synthesize delegate = mDelegate;

-(void)beginLoadingMuniDataWithDelegate:(MuniMapViewController *)delegate
{
	NSLog(@"start loading data");
	if (!self.rawDataDictionary) {
		self.rawDataDictionary = [[NSMutableDictionary alloc] init];
	}
	if (!self.routes){
		self.routes = [[NSMutableDictionary alloc] init];
	}
	self.delegate = delegate;
	// Create the request.
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:muniRoutlistUrl]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] setActiveConnections:[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections]+1];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		NSMutableData *dataObject = [[NSMutableData alloc] init];
		[self.rawDataDictionary setObject:dataObject forKey:[theConnection description]];
	} else {
		NSLog(@"the connection failed");
	}
	
	NSLog(@"the connection %@", theConnection);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//we just got new data: add it to the appropriate dictionary position
	[[self.rawDataDictionary objectForKey:[connection description]] appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] setActiveConnections:[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections]-1];
	if(![(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections])
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
	[[self.rawDataDictionary objectForKey:[connection description]] release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] setActiveConnections:[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections]-1];
	if(![(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections])
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	//load the data into the parser and lets get stuff out.
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[self.rawDataDictionary objectForKey:[connection description]]] autorelease];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
	
    // release the connection, and the data object
    [connection release];
	[[self.rawDataDictionary objectForKey:[connection description]] release];
}

-(void)addNewRouteToDataStructure:(NSString *)routeTag{
	
		// Create the request.
		NSString *urlString = [NSString stringWithFormat:@"%@%@", routeDetailURL, routeTag];
		NSURL *url = [[NSURL alloc] initWithString:urlString];
		NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:60.0];
		[url release];
		// create the connection with the request
		// and start loading the data
		NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		if (theConnection) {
			[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] setActiveConnections:[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections]+1];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			
			
			
			// Create the NSMutableData to hold the received data.
			// receivedData is an instance variable declared elsewhere.
			NSMutableData *dataObject = [[NSMutableData alloc] init];
			[self.rawDataDictionary setObject:dataObject forKey:[theConnection description]];
		} else {
			NSLog(@"the connection failed");
		}
		
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	//NSLog(@"start element name %@, namespace %@ qualified %@, attributes %@", elementName, namespaceURI, qualifiedName, attributeDict);
	if ([elementName isEqualToString:@"route"]){
		NSString *tag = [attributeDict objectForKey:@"tag"];
		self.currentTag = tag;
		if (![self.routes objectForKey:tag]){
			[self addNewRouteToDataStructure:tag];
			[self.routes setObject:[[NSMutableArray alloc] init] forKey:tag];
		}
	}
	else if ([elementName isEqualToString:@"body"]) {
		//NSLog(@"do nothing with body");
	}
	
	//if it is a 'stop' and it contains a 'lat' (bad data otherwise)
	else if ([elementName isEqualToString:@"stop"] && [attributeDict objectForKey:@"lat"]){
		[[self.routes objectForKey:self.currentTag] addObject:attributeDict];
		
		CLLocationCoordinate2D center;
		center.latitude = [[attributeDict objectForKey:@"lat"] floatValue];
		center.longitude = [[attributeDict objectForKey:@"lon"] floatValue];
		
		//gdirect.com
		//if([(MuniMapViewController *)self.delegate respondsToSelector:@selector(pointLoaded)])
			[(MuniMapViewController *)self.delegate pointLoaded:center forLine:self.currentTag withStopId:[attributeDict objectForKey:@"stopId"]];
	}
	else {
		//NSLog(@"and we found a %@", elementName);
		//NSLog(@"start element name %@, namespace %@ qualified %@, attributes %@", elementName, namespaceURI, qualifiedName, attributeDict);

	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	self.currentTag = nil;	
}
-(void)dealloc
{
	[super dealloc];
	self.routes = nil;
	self.rawDataDictionary = nil;
	self.currentTag = nil;
	self.delegate = nil;
}

@end
