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
/* @import "Model/CMColumnManager.j" */

@implementation AppController : CPObject
{
	CPTextField label;
	
	CPWindow window;
	CMHeaderView headerView;
	CMMainView mainView;
	CMSidebarView sidebarView;
	
	CMURL groupingURL;
	CMCSV groupingCSV;
	
	CMURL valuesURL;
	CMCSV valuesCSV;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification {
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(urlLoaded:) name:CMURLLoadedNotification object:nil];
	
/* 	[self setupColumnManager]; */
	[self setupViews];
	[self parseArguments];
	
	// Uncomment the following line to turn on the standard menu bar.
	//[CPMenu setMenuBarVisible:YES];
}

- (void)parseArguments {
	var /* CPArray */ arguments = [[CPApplication sharedApplication] arguments];
	
	if ([arguments count]) {
		var arg1 = [arguments objectAtIndex:0];
		groupingURL = [[CMURL alloc] initWithURLString:[CPString stringWithFormat:@"/input_data/%@-grouping.csv", arg1]
		                        completionNotification:CMURLLoadedNotification];
/*
		valuesURL = [[CMURL alloc] initWithURLString:[CPString stringWithFormat:@"/input_data/%@-values.csv", arg1]
		                      completionNotification:CMURLLoadedNotification];
*/
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
		valuesCSV = [[CMCSV alloc] initWithCSVText:[notifyObj data]];
		[self valuesPostProcessing];
	}
	else if ([notifyObj isEqual:groupingURL]) {
		groupingCSV = [[CMCSV alloc] initWithCSVText:[notifyObj data]];
		[self groupingPostProcessing];
	}
}

- (void)valuesPostProcessing {
}

- (void)groupingPostProcessing {
	var groups = [CPMutableDictionary dictionary];
	var columns = [CPMutableArray array];
	
	// Setup the All group.
	var allGroup = [[CMColumnGroup alloc] initWithName:@"All"];
	[allGroup setAllGroup:YES];
	
	// Setup the Solo group.
	var soloGroup = [[CMColumnGroup alloc] initWithName:@"Solo"];
	[soloGroup setSoloGroup:YES];
	
	// Now read the rest of the columns and groups from groupingCSV.
	var groupDictionaries = [groupingCSV dictionaryArray];
	for (var i = 0; i < [groupDictionaries count]; i++) {
		var /* CPDictionary */ groupDictionary = [groupDictionaries objectAtIndex:i];

		var /* CPString */ columnName = [groupDictionary objectForKey:CMOldIDColumnName];
		var /* CPString */ spreadsheet = [groupDictionary objectForKey:CMSpreadsheetColumnName];
		var /* CPString */ groupName = [groupDictionary objectForKey:CMNewIDColumnName];
		
		if ([columnName length]) {
			var c = [[CMColumn alloc] initWithName:columnName spreadsheet:spreadsheet];
			if (c) [columns addObject:c];
		
			if ([groupName length]) {
				// See if we already have a group with this name.
				var groupObject = [groups objectForKey:groupName];
				if (!groupObject) {
					// Doesn't exist, create it.
					groupObject = [[CMColumnGroup alloc] initWithName:groupName];
					[groups setObject:groupObject forKey:groupName];
				}
				
				[c setGroup:groupObject];
			}
		}
	}
	
	var groupArray = [CPMutableArray arrayWithObjects:allGroup, soloGroup, nil];
	var parsedGroups = [groups allValues];
	
	// Sort the groups
	if (parsedGroups) {
		var sortedArray = [parsedGroups mutableCopy];
		[sortedArray sortUsingSelector:@selector(compare:)];
		[groupArray addObjectsFromArray:sortedArray];
	}
	
	// Sort the columns
	[columns sortUsingSelector:@selector(compare:)];
	
	[[CMColumnManager sharedManager] setColumnGroups:groupArray ? groupArray : [CPArray array]];
	[[CMColumnManager sharedManager] setColumns:columns ? columns : [CPArray array]];
	
	// Tell the UI to update.
	[sidebarView updateContent];
}

@end
