/*
 * CMColumnManager.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 25, 2014.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

var CMColumnManager_sharedManager = nil;

@implementation CMColumnManager : CPObject
{
	// An array of CMColumn objects.  These are all the columns present in source spreadsheets.
	CPArray columns @accessors;

	// An array of CMColumnGroup objects.  These show up in the sidebar.
	CPArray columnGroups @accessors;
}

+ (CMColumnManager)sharedManager {
	if (!CMColumnManager_sharedManager) CMColumnManager_sharedManager = [[CMColumnManager alloc] init];
	return CMColumnManager_sharedManager;
}

- (CPArray)soloColumns {
	// Return the columns without a group.
	var retArray = [CPMutableArray array];
	if ([columns count]) [retArray addObjectsFromArray:columns];
	
	for (var i = 0; i < [columnGroups count]; i++) {
		var group = [columnGroups objectAtIndex:i];
		if ([group allGroup]) continue;			// Don't remove All columns.
		if ([group soloGroup]) continue;		// Stops a circular call stack.
		
		var members = [[columnGroups objectAtIndex:i] members];
		if ([members count]) {
			[retArray removeObjectsInArray:members];
		}
	}
	
	return retArray;
}

@end
