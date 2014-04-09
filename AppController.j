/*
 * AppController.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Base/CMURL.j"
@import "Base/CMCommon.j"

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
	var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
	contentView = [theWindow contentView];

	var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];

	[label setStringValue:@"Hello World!"];
	[label setFont:[CPFont boldSystemFontOfSize:24.0]];

	[label sizeToFit];

	[label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
	[label setCenter:[contentView center]];

	[contentView addSubview:label];
	
	var arguments = [[CPApplication sharedApplication] arguments];
	var urls = [CPMutableArray array];
	for (var i = 0; i < [arguments count]; i++) {
		[urls addObject:[[CMURL alloc] initWithURLString:[arguments objectAtIndex:i] notificationString:CMURLLoadedNotification]];
	}

	[theWindow orderFront:self];

	// Uncomment the following line to turn on the standard menu bar.
	//[CPMenu setMenuBarVisible:YES];
}

@end
