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
	
	// A dictionary of CPArray objects.  Each array has string values.
	CPDictionary columnValues @accessors;
}

+ (CMColumnManager)sharedManager {
	if (!CMColumnManager_sharedManager) CMColumnManager_sharedManager = [[CMColumnManager alloc] init];
	return CMColumnManager_sharedManager;
}

- (id)init {
	self = [super init];
	if (self) {
		columns = [CPArray array];
		columnGroups = [CPArray array];
	}
	return self;
}

- (CPArray)soloColumns {
	// Return the columns without a group.
	var retArray = [CPMutableArray array];
	
	for (var i = 0; i < [columns count]; i++) {
		var column = [columns objectAtIndex:i];
		if (![column group]) [retArray addObject:column];
	}
	
	return retArray;
}

- (CPArray)columnsInGroup:(CMColumnGroup)group {
	if ([group soloGroup]) {
		return [self soloColumns];
	}
	else if ([group allGroup]) {
		return [self columns];
	}
	else {
		var retArray = [CPMutableArray array];
		var count = [columns count];
		for (var i = 0; i < count; i++) {
			var column = [columns objectAtIndex:i];
			if ([column group] == group) {
				[retArray addObject:column];
			}
		}
		
		return retArray;	
	}	
}

/* Sometimes we duplicate CMColumn objects (when archiving/unarchiving during a drag operation, for instance).  This method will find the built-in column that is equal to the column passed in. */
- (CMColumn)columnMatchingExternalColumn:(CMColumn)extColumn {
	for (var i = 0; i < [columns count]; i++) {
		var col = [columns objectAtIndex:i];
		if ([col isEqualToColumn:extColumn]) {
			return col;
		}
	}
	return nil;
}

- (CPArray)valuesForColumn:(CMColumn)column {
	
}

@end
