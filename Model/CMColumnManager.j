/*
 * CMColumnManager.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 25, 2014.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "CMColumn.j"

var CMColumnManager_sharedManager = nil;

@implementation CMColumnManager : CPObject
{
	// An array of CMColumn objects.  These are all the columns present in source spreadsheets.
	CPArray columns @accessors;

	// An array of CMColumnGroup objects.  These show up in the sidebar.
	CPArray columnGroups @accessors;
	
	CPView sidebarView @accessors;
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

- (CMColumn)columnWithName:(CPString)name spreadsheet:(CPString)spreadsheet {
	var searchColumn = [[CMColumn alloc] initWithName:name spreadsheet:spreadsheet];
	return [self columnMatchingExternalColumn:searchColumn];
}

- (void)setColumnGroups:(CPArray)aGroupArray {
	var normalGroups = [CPMutableArray array];
	var /* CPColumnGroup */ allGroup = nil;
	var /* CPColumnGroup */ soloGroup = nil;
	
	for (var i = 0; i < [aGroupArray count]; i++) {
		var /* CPColumnGroup */ group = aGroupArray[i];
		if ([group allGroup]) {
			allGroup = group;
		}
		else if ([group soloGroup]) {
			soloGroup = group;
		}
		else {
			[normalGroups addObject:group];
		}
	}
	
	// Check if there are any columns that are in groups no longer a part of normalGroups.  If so, then we need to set those column groups to nil.
	for (var i = 0; i < [columns count]; i++) {
		var /* CPColumn */ col = [columns objectAtIndex:i];
		if (![normalGroups containsObject:[col group]]) {
			[col setGroup:nil];
		}
	}

	[normalGroups sortUsingSelector:@selector(compare:)];
	[normalGroups insertObject:soloGroup atIndex:0];
	[normalGroups insertObject:allGroup atIndex:0];
	columnGroups = normalGroups;
	
	// Tell the UI to update.
	[sidebarView updateContent];
}

@end
