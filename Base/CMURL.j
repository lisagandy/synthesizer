/*
 * CMURL.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMURL : CPObject
{
	CPString completionNotificationName;

	CPString urlString;
	CPURLConnection connection;

	CPData downloadedData;
	BOOL downloadCompleted;
	BOOL downloadFailed;
}

- (void)initWithURLString:(CPString)url completionNotification:(CPString)completionNotification {
	self = [super init];
	if (self) {
		urlString = url;
		completionNotificationName = completionNotification;
		[self loadInBackground];
	}
	return self;
}

- (void)loadInBackground {
	var request = [CPURLRequest requestWithURL:urlString];
	connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data {
}

- (void)connectionDidFinishLoading:(CPURLConnection)connection {
	
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError {
	if (aConnection == connection)
	alert("There was an error loading this URL (" + urlString + ").  Please try again later.");

	[self clearConnection:aConnection];
}

@end
