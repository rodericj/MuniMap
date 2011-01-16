//
//  StopDetailViewController.m
//  MuniMap
//
//  Created by roderic campbell on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StopDetailViewController.h"

#define muniStopPredictionUrl @"http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&stopId="

@implementation StopDetailViewController

@synthesize stopId;
@synthesize incomingData = mIncomingData;
@synthesize lookup = mLookup;
@synthesize currentLookup = mCurrentLookup;

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//Do we know what the stop number or stop id is?
	NSLog(@"stop id is %d", self.stopId);

	//start the network request
	NSString *url = [NSString stringWithFormat:@"%@%d", muniStopPredictionUrl, self.stopId];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		self.incomingData = [[NSMutableData alloc] init];
	} else {
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
	[self.incomingData release];
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

	//load the data into the parser and lets get stuff out.
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.incomingData];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
	
    // release the connection, and the data object
	[self.incomingData release];
    [connection release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	
	//NSLog(@"start element name %@, namespace %@ qualified %@, attributes %@", elementName, namespaceURI, qualifiedName, attributeDict);

	if ([elementName isEqualToString:@"predictions"]) {
		//NSLog(@"predictions start element name %@, attributes %@", elementName, attributeDict);
		NSLog(@"i see the %@", [attributeDict objectForKey:@"routeTitle"]);
		if (!self.lookup) {
			self.lookup = [[NSMutableDictionary alloc] init];
		}
		[self.lookup setObject:[[NSMutableArray alloc] init] forKey:[attributeDict objectForKey:@"routeTitle"]];
		self.currentLookup = [attributeDict objectForKey:@"routeTitle"];
	}
	if ([elementName isEqualToString:@"prediction"]) {
//		NSLog(@"prediction start element name %@, attributes %@", elementName, attributeDict);
		NSLog(@"it gets here at %@, add it to %@", [attributeDict objectForKey:@"minutes"], self.currentLookup);
		[(NSMutableArray *)[self.lookup objectForKey:self.currentLookup] addObject:[attributeDict objectForKey:@"minutes"]];
	}
	NSLog(@"self.lookup %@", self.lookup);
}	
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	NSLog(@"%d rows ", [self.lookup count]);
	
    return [self.lookup count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.lookup allKeys] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSString *key = [[self.lookup allKeys] objectAtIndex:section];
	return [[self.lookup objectForKey:key] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSString *key = [[self.lookup allKeys] objectAtIndex:indexPath.section];

	[cell setText:[[self.lookup objectForKey:key] objectAtIndex:indexPath.row]];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
}


@end

