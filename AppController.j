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
@import "Views/CMMainView.j"
@import "Views/CMSidebarView.j"

@implementation AppController : CPObject
{
	CPTextField label;
	CPArray csvFileURLs;
	
	CMMainView mainView;
	CMSidebarView sidebarView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(urlLoaded:) name:CMURLLoadedNotification object:nil];
	
	[self parseArguments];
	[self setupViews];
	
	// Uncomment the following line to turn on the standard menu bar.
	//[CPMenu setMenuBarVisible:YES];
}

- (void)parseArguments {
	var arguments = [[CPApplication sharedApplication] arguments];
	csvFileURLs = [CPMutableArray array];
	for (var i = 0; i < [arguments count]; i++) {
		[csvFileURLs addObject:[[CMURL alloc] initWithURLString:[arguments objectAtIndex:i] completionNotification:CMURLLoadedNotification]];
	}
}

- (void)setupViews {
	var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
	contentView = [theWindow contentView];
	var bounds = [contentView bounds];

	sidebarView = [[CMSidebarView alloc] initWithFrame:CGRectMake(bounds.origin.x - 2., bounds.origin.y, 240. + 2., bounds.size.height)];	// 2px to accomodate from the horzontal spacing in the collection view.
	[sidebarView setAutoresizingMask:CPViewMaxXMargin | CPViewHeightSizable];
	
	mainView = [[CMMainView alloc] initWithFrame:CGRectMake(bounds.origin.x + 240., bounds.origin.y, bounds.size.width - 240., bounds.size.height)];
	[mainView setBackgroundColor:[CPColor blackColor]];
	[mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

	[contentView addSubview:mainView];
	[contentView addSubview:sidebarView];

	[theWindow orderFront:self];
}

- (void)urlLoaded:(CPNotification)notify {
/* 	alert([[notify object] data]); */
}

@end
