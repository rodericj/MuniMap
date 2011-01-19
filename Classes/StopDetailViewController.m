//
//  StopDetailViewController.m
//  MuniMap
//
//  Created by roderic campbell on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StopDetailViewController.h"
#import "MuniMapAppDelegate.h"
#define muniStopPredictionUrl @"http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&stopId="

@implementation StopDetailViewController

@synthesize stopId;
@synthesize incomingData = mIncomingData;
@synthesize lookup = mLookup;
@synthesize currentLookup = mCurrentLookup;

#pragma mark -
#pragma mark View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if(!self.incomingData){
		//start the network request
		NSString *url = [NSString stringWithFormat:@"%@%d", muniStopPredictionUrl, self.stopId];
		NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:60.0];
		
		// create the connection with the request
		// and start loading the data
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		if (conn) {
			// Create the NSMutableData to hold the received data.
			// receivedData is an instance variable declared elsewhere.
			self.incomingData = [[NSMutableData alloc] init];
			[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] setActiveConnections:[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections]+1];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			
		} else
			NSLog(@"the connection failed");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//we just got new data: add it to the appropriate dictionary position
	[self.incomingData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] setActiveConnections:[(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections]-1];
	if(![(MuniMapAppDelegate *)[[UIApplication sharedApplication] delegate] activeConnections])
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    // release the connection, and the data object
    [connection release];
	self.incomingData = nil;

    // receivedData is declared as a method instance elsewhere	
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
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:self.incomingData] autorelease];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
	
    // release the connection, and the data object
	self.incomingData = nil;
    [connection release];
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	NSLog(@"the stop info %@, %@", elementName, attributeDict);
	//predictions (with an 's') come first in the XML, use the prediction element to describe the route title
	//  ex: 1-california. 
	//Use this as the beginning of our dictionary key
	if ([elementName isEqualToString:@"predictions"]) {
		if (!self.lookup)
			self.lookup = [[NSMutableDictionary alloc] init];	
		if ([attributeDict objectForKey:@"dirTitleBecauseNoPredictions"]) {
			NSString *routeName = [NSString stringWithFormat:@"%@\n%@\n%@", 
								   [attributeDict objectForKey:@"routeTitle"],
								   [attributeDict objectForKey:@"dirTitleBecauseNoPredictions"],
								   [attributeDict objectForKey:@"stopTitle"]];
			self.currentLookup = routeName;
			[self.lookup setObject:[[NSMutableArray alloc] init] forKey:self.currentLookup];
		}
		else 
			self.currentLookup = [NSString stringWithFormat:@"%@ \n%@",
								  [attributeDict objectForKey:@"routeTitle"],
								  [attributeDict objectForKey:@"stopTitle"]];
	}
	
	//direction comes next. This, obviously, describes the direction of the route.
	//  ex: Outbound to Geary & 33rd Ave
	//Add this to the end of the string we started above, and create an empty array to store the predictions
	if ([elementName isEqualToString:@"direction"]) {
		self.currentLookup = [NSString stringWithFormat:@"%@ %@", self.currentLookup, [attributeDict 
																					   objectForKey:@"title"]];
		[self.lookup setObject:[[NSMutableArray alloc] init] forKey:self.currentLookup];
	}
	
	//Finally one or more prediction objects show up in the XML
	if ([elementName isEqualToString:@"prediction"])
		[(NSMutableArray *)[self.lookup objectForKey:self.currentLookup] addObject:[attributeDict 
																					objectForKey:@"minutes"]];
	
}	

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	//now that we've got all of the data in our internal data structure, let's reload
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//simply the number of bus lines we found at this stop
    return [self.lookup count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[self.lookup allKeys] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	// Return the number of rows in the section.
	NSString *key = [[self.lookup allKeys] objectAtIndex:section];
	
	if ([[self.lookup objectForKey:key] count])
		return [[self.lookup objectForKey:key] count];
	
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
	NSString *key = [[self.lookup allKeys] objectAtIndex:indexPath.section];
	//NSString *key = [[self.lookup allKeys] objectAtIndex:section];
	if ([[self.lookup objectForKey:key] count])
	{
		NSString *text = [NSString stringWithFormat:@"%@ minutes", [[self.lookup objectForKey:key] objectAtIndex:indexPath.row]];
		cell.textLabel.text = text;
	}
	else
		cell.textLabel.text = @"No predictions at this time.";
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	//NSLog(@"dealloc of StopDetailViewController");
//	//release all of the NSMutableArray of predictions that I created in the lookup dictionary
//	for (NSString *k in self.lookup)
//		[[self.lookup objectForKey:k] release];
//	NSLog(@"dealloc of StopDetailViewController 2");

	//self.lookup = nil;
	//self.currentLookup = nil;

	//Yes this should be relased, just double checking
	//self.incomingData = nil;
}


@end

