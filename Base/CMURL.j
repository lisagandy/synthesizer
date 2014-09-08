/*
 * CMURL.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 *
 * This class handles loading content from a remote URL.  Once the content 
 * has finished loading, the specified completionNotificationName is posted 
 * and observers can pick up the data.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMURL : CPObject
{
	CPString completionNotificationName;

	CPString urlString @accessors;
	CPURLConnection connection;

	CPString data @accessors;
	BOOL loading @accessors;
	BOOL completed @accessors;
	BOOL failed @accessors;
}

- (void)initWithURLString:(CPString)url completionNotification:(CPString)completionNotification {
	self = [super init];
	if (self) {
		urlString = url;
		completionNotificationName = completionNotification;
		loading = NO;
		completed = NO;
		failed = NO;
		[self loadInBackground];
	}
	return self;
}

- (void)loadInBackground {
	data = @"";
	loading = YES;
	completed = NO;
	failed = NO;
	var request = [CPURLRequest requestWithURL:urlString];
	connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)d {
	if (aConnection == connection) {
		data = [data stringByAppendingString:d];
	}
}

- (void)connectionDidFinishLoading:(CPURLConnection)aConnection {
	if (aConnection == connection) {
		completed = YES;
		loading = NO;
		[[CPNotificationCenter defaultCenter] postNotificationName:completionNotificationName object:self];
	}
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError {
	if (aConnection == connection) {
		alert("Unable to load '" + urlString + "'.  Please try again later.");
		failed = YES;
		completed = YES;
		loading = NO;
	}
}

@end
