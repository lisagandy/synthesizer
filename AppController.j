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
		valuesCSV = [[CMCSV alloc] initWithCSVText:[notifyObj data]];
		[self valuesPostProcessing];
	}
}

- (void)valuesPostProcessing {	
	var groups = [CPMutableDictionary dictionary];
	var columns = [CPMutableArray array];
	
	// Setup the All group.
	var allGroup = [[CMColumnGroup alloc] initWithName:@"All"];
	[allGroup setAllGroup:YES];
	
	// Setup the Solo group.
	var soloGroup = [[CMColumnGroup alloc] initWithName:@"Not Grouped"];
	[soloGroup setSoloGroup:YES];

	// Get our value arrays from the parsed CSV file.	
	var valueArrays = [valuesCSV arrayArray];
	if ([valueArrays count] < 2) return;

	// The first 2 rows of the CSV files are the column names and the spreadsheet names.
	var /* CPArray */ columnNames = valueArrays[0];
	var /* CPArray */ spreadsheetNames = valueArrays[1];
	
	// For every other column, get the original values, the modified values, the group name, etc.
	for (var columnIndex = 0; columnIndex < [columnNames count] - 1; columnIndex += 2) {
		// The column and spreadsheet we are working with.
		var columnName = columnNames[columnIndex];
		var spreadsheetName = spreadsheetNames[columnIndex];
		var groupName = columnNames[columnIndex+1];
		
		if ([columnName length]) {
			// Create the column object.
			var c = [[CMColumn alloc] initWithName:columnName spreadsheet:spreadsheetName];
			if (c) [columns addObject:c];
		
			// Check and attempt to create the group object.
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

			// Read the original and modified values.
			var thisColumnOriginalValues = [CPMutableArray array];
			var thisColumnModifiedValues = [CPMutableArray array];
			for (var i = 2; i < [valueArrays count]; i++) {
				var /* CPArray */ lineArray = [valueArrays objectAtIndex:i];
				
				// Original value for this line.
				if ([lineArray count] > columnIndex) [thisColumnOriginalValues addObject:lineArray[columnIndex]];
				else                                 [thisColumnOriginalValues addObject:@""];
				
				// Modified value for this line.
				if ([lineArray count] > columnIndex + 1) [thisColumnModifiedValues addObject:lineArray[columnIndex + 1]];
				else                                     [thisColumnModifiedValues addObject:@""];
			}
			
			// Start at the end of the file and work our way up.  Remove rows that are "" "" on both columns.
			while ([thisColumnModifiedValues count] > 0) {
				if (([[thisColumnModifiedValues lastObject] length] == 0) && ([[thisColumnOriginalValues lastObject] length] == 0)) {
					[thisColumnOriginalValues removeLastObject];
					[thisColumnModifiedValues removeLastObject];
				}
				else {
					break;
				}
			}
			
			[c setOriginalValues:thisColumnOriginalValues];
			[c setModifiedValues:thisColumnModifiedValues];
		}
	}

	// Now we have an array of columns and a dictionary of groups.  
	
	// Remove any groups that only have one column in them (if the group name is the same as the column name).
	for (var i = 0; i < [columns count]; i++) {
		var /* CMColumn */ column = columns[i];
		var /* CMColumnGroup */ columnGroup = [column group];
		
		if (columnGroup) {
			if ([[columnGroup name] isEqualToString:[column name]]) {
				// Check to see if any other columns have this same group name.
				var /* BOOL */ loneGroup = 1;
				for (var j = 0; j < [columns count]; j++) {
					if (j == i) continue;
					
					if ([columns[j] group] == columnGroup) {
						loneGroup = 0;
						break;
					}
				}
				
				if (loneGroup) {
					// Get rid of this group.
					[column setGroup:nil];
					[groups removeObjectForKey:[columnGroup name]];
				}
			}
		}
	}
	
	// Sort the columns
	[columns sortUsingSelector:@selector(compare:)];
	
	// Combine the groups
	var groupArray = [CPMutableArray arrayWithObjects:allGroup, soloGroup, nil];
	var parsedGroups = [groups allValues];
	if (parsedGroups) [groupArray addObjectsFromArray:parsedGroups];
	
	[[CMColumnManager sharedManager] setColumns:columns ? columns : [CPArray array]];
	[[CMColumnManager sharedManager] setColumnGroups:groupArray ? groupArray : [CPArray array]];
}

@end
