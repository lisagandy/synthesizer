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
@import "Base/CMCSV.j"
@import "Views/CMMainView.j"
@import "Views/CMSidebarView.j"
@import "Views/CMHeaderView.j"
@import "Model/CMColumn.j"
@import "Model/CMColumnGroup.j"
@import "Model/CMColumnManager.j"

@implementation AppController : CPObject
{
	CPTextField label;
	
	CPWindow window;
	CMHeaderView headerView;
	CMMainView mainView;
	CMSidebarView sidebarView;
	
	CMURL valuesURL;
	CMCSV valuesCSV;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification {
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(urlLoaded:) name:CMURLLoadedNotification object:nil];
	
	// Start with an empty CSV file (this will make sure we add the all and solo column groups).
	[[CMColumnManager sharedManager] importCSV:nil];
	
	[self setupViews];
	[self parseArguments];
	
	// Uncomment the following line to turn on the standard menu bar.
	//[CPMenu setMenuBarVisible:YES];
}

- (void)parseArguments {
	var /* CPArray */ arguments = [[CPApplication sharedApplication] arguments];
	
	if ([arguments count]) {
		var arg1 = [arguments objectAtIndex:0];

		valuesURL = [[CMURL alloc] initWithURLString:[CPString stringWithFormat:@"/input_data/%@-values.csv", arg1]
		                      completionNotification:CMURLLoadedNotification];
	}
}

- (void)setupViews {
	window = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
	var contentView = [window contentView];
	var bounds = [contentView bounds];

	var headerViewHeight = 40;
	var sidebarWidth = 300;
	var splitterWidth = 2;
	headerView = [[CMHeaderView alloc] initWithFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, headerViewHeight)];
	[headerView setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin];

	mainView = [[CMMainView alloc] initWithFrame:CGRectMake(bounds.origin.x + sidebarWidth, bounds.origin.y + headerViewHeight - 1, bounds.size.width - sidebarWidth, bounds.size.height - headerViewHeight)];
	[mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

	sidebarView = [[CMSidebarView alloc] initWithFrame:CGRectMake(bounds.origin.x - splitterWidth, bounds.origin.y + headerViewHeight - 1, sidebarWidth + splitterWidth, bounds.size.height - headerViewHeight)];
	[sidebarView setAutoresizingMask:CPViewMaxXMargin | CPViewHeightSizable];
	
	var splitView = [[CPView alloc] initWithFrame:CGRectMake(bounds.origin.x + sidebarWidth, bounds.origin.y + headerViewHeight, splitterWidth, bounds.size.height - headerViewHeight)];
	[splitView setBackgroundColor:[CPColor darkGrayColor]];
	[splitView setAutoresizingMask:CPViewMaxXMargin | CPViewHeightSizable];
	
	[[CMColumnManager sharedManager] setSidebarView:sidebarView];
	
	[headerView setMainView:mainView];
	[sidebarView setMainView:mainView];
	
	[contentView addSubview:mainView];
	[contentView addSubview:sidebarView];
	[contentView addSubview:headerView];
	[contentView addSubview:splitView];

	[window orderFront:self];
}

- (void)urlLoaded:(CPNotification)notify {
	var notifyObj = [notify object];

	if ([notifyObj isEqual:valuesURL]) {
		valuesCSV = [[CMCSV alloc] init];
		[valuesCSV parseCSV:[notifyObj data]];
		[[CMColumnManager sharedManager] importCSV:valuesCSV];
	}
}

@end
