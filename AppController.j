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
@import "Views/CMHeaderView.j"
@import "Model/CMColumn.j"
@import "Model/CMColumnGroup.j"
/* @import "Model/CMColumnManager.j" */

@implementation AppController : CPObject
{
	CPTextField label;
	CPArray csvFileURLs;
	
	CPWindow window;
	CMHeaderView headerView;
	CMMainView mainView;
	CMSidebarView sidebarView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification {
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(urlLoaded:) name:CMURLLoadedNotification object:nil];
	
	[self parseArguments];
	[self setupColumnManager];
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

- (void)setupColumnManager {
	var allGroup = [[CMColumnGroup alloc] initWithName:@"All"];
	[allGroup setAllGroup:YES];
	var soloGroup = [[CMColumnGroup alloc] initWithName:@"Solo"];
	[soloGroup setSoloGroup:YES];

	var columnFoo = [[CMColumn alloc] initWithName:@"foo"];
	var columnGoo = [[CMColumn alloc] initWithName:@"goo"];
	var columnRoo = [[CMColumn alloc] initWithName:@"roo"];
	
	var derivedA = [[CMColumnGroup alloc] initWithName:@"A"]
	[derivedA setMembers:@[ columnFoo, columnGoo, columnRoo ]];
	
	var derivedColumns = @[ allGroup,
							soloGroup,
							derivedA,
							[[CMColumnGroup alloc] initWithName:@"B"],
							[[CMColumnGroup alloc] initWithName:@"C"],
							[[CMColumnGroup alloc] initWithName:@"D"],
							[[CMColumnGroup alloc] initWithName:@"E"],
							[[CMColumnGroup alloc] initWithName:@"F"],
							[[CMColumnGroup alloc] initWithName:@"G"],
							[[CMColumnGroup alloc] initWithName:@"H"],
							[[CMColumnGroup alloc] initWithName:@"I"],
							[[CMColumnGroup alloc] initWithName:@"J"],
							[[CMColumnGroup alloc] initWithName:@"K"],
							[[CMColumnGroup alloc] initWithName:@"L"],
							[[CMColumnGroup alloc] initWithName:@"M"] ];
	[[CMColumnManager sharedManager] setColumnGroups:derivedColumns];
	
	var sourceColumns = @[ columnFoo, columnGoo, columnRoo,
						   [[CMColumn alloc] initWithName:@"101"],
						   [[CMColumn alloc] initWithName:@"102"],
						   [[CMColumn alloc] initWithName:@"103"],
						   [[CMColumn alloc] initWithName:@"104"],
						   [[CMColumn alloc] initWithName:@"105"],
						   [[CMColumn alloc] initWithName:@"106"],
						   [[CMColumn alloc] initWithName:@"107"],
						   [[CMColumn alloc] initWithName:@"108"],
						   [[CMColumn alloc] initWithName:@"109"],
						   [[CMColumn alloc] initWithName:@"110"],
						   [[CMColumn alloc] initWithName:@"111"],
						   [[CMColumn alloc] initWithName:@"112"],
						   [[CMColumn alloc] initWithName:@"113"],
						   [[CMColumn alloc] initWithName:@"114"],
						   [[CMColumn alloc] initWithName:@"115"],
						   [[CMColumn alloc] initWithName:@"116"],
						   [[CMColumn alloc] initWithName:@"117"],
						   [[CMColumn alloc] initWithName:@"118"],
						   [[CMColumn alloc] initWithName:@"119"],
						   [[CMColumn alloc] initWithName:@"120"],
						   [[CMColumn alloc] initWithName:@"121"] ];
	[[CMColumnManager sharedManager] setColumns:sourceColumns];
}

- (void)setupViews {
	window = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
	var contentView = [window contentView];
	var bounds = [contentView bounds];

	var headerViewHeight = 40;
	headerView = [[CMHeaderView alloc] initWithFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, headerViewHeight)];
	[headerView setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin];

	mainView = [[CMMainView alloc] initWithFrame:CGRectMake(bounds.origin.x + 240., bounds.origin.y + headerViewHeight - 1, bounds.size.width - 240., bounds.size.height - headerViewHeight)];
	[mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

	sidebarView = [[CMSidebarView alloc] initWithFrame:CGRectMake(bounds.origin.x - 2., bounds.origin.y + headerViewHeight - 1, 240. + 2., bounds.size.height - headerViewHeight)];	// 2px to accomodate from the horzontal spacing in the collection view.
	[sidebarView setAutoresizingMask:CPViewMaxXMargin | CPViewHeightSizable];
	[sidebarView setMainView:mainView];
	
	var splitView = [[CPView alloc] initWithFrame:CGRectMake(bounds.origin.x + 240., bounds.origin.y + headerViewHeight, 2., bounds.size.height - headerViewHeight)];
	[splitView setBackgroundColor:[CPColor darkGrayColor]];
	[splitView setAutoresizingMask:CPViewMaxXMargin | CPViewHeightSizable];
	
	[contentView addSubview:mainView];
	[contentView addSubview:sidebarView];
	[contentView addSubview:headerView];
	[contentView addSubview:splitView];

	[window orderFront:self];
}

- (void)urlLoaded:(CPNotification)notify {
/* 	alert([[notify object] data]); */
}

@end
