/*
 * CMColumnManager.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 *
 * This class is meant to be used as a singleton.  It keeps track of all
 * the spreadsheet columns that were imported, as well as a list of column
 * groups.  The column manager has convenience methods to fetch the list 
 * of columns that belong to a certain group, or no particular group.
 * 
 * CMColumnManager also has the methods that actually do the import/export work.
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

/*** CSV Handling ***/
- (void)importCSV:(CMCSV)csvFile {
	var groups = [CPMutableDictionary dictionary];
	var cols = [CPMutableArray array];
	
	// Setup the All group.
	var allGroup = [[CMColumnGroup alloc] initWithName:@"All"];
	[allGroup setAllGroup:YES];
	
	// Setup the Solo group.
	var soloGroup = [[CMColumnGroup alloc] initWithName:@"Not Grouped"];
	[soloGroup setSoloGroup:YES];

	// Get our value arrays from the parsed CSV file.	
	var valueArrays = [csvFile lines];
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
			if (c) [cols addObject:c];
		
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
	for (var i = 0; i < [cols count]; i++) {
		var /* CMColumn */ column = cols[i];
		var /* CMColumnGroup */ columnGroup = [column group];
		
		if (columnGroup) {
			if ([[columnGroup name] isEqualToString:[column name]]) {
				// Check to see if any other columns have this same group name.
				var /* BOOL */ loneGroup = 1;
				for (var j = 0; j < [cols count]; j++) {
					if (j == i) continue;
					
					if ([cols[j] group] == columnGroup) {
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
	[cols sortUsingSelector:@selector(compare:)];
	
	// Combine the groups
	var groupArray = [CPMutableArray arrayWithObjects:allGroup, soloGroup, nil];
	var parsedGroups = [groups allValues];
	if (parsedGroups) [groupArray addObjectsFromArray:parsedGroups];
	
	[self setColumns:cols ? cols : [CPArray array]];
	[self setColumnGroups:groupArray ? groupArray : [CPArray array]];
}

- (CMCSV)exportCSV {
	var /* CPArray[CPArray][CPString] */ lines = [CPMutableArray array];		// This will be used for the lines value in the return CSV object.

	var maxValueCount = 0;														// We need to know the max number of values we need to print, spreadsheets might each have different numbers of rows.

	// Create the column order.  Columns should be ordered by group name first, and then solo columns at the end.
	var orderedColumns = [CPMutableArray array];
	for (var groupIndex = 0; groupIndex < [columnGroups count]; groupIndex++) {
		var /* CMColumnGroup */ group = columnGroups[groupIndex];
		var /* CPArray[CMColumn] */ groupColumns = [self columnsInGroup:group];
		if (groupColumns) [orderedColumns addObjectsFromArray:groupColumns];
	}
	var /* CPArray[CMColumn] */ solo = [self soloColumns];
	if (solo) [orderedColumns addObjectsFromArray:solo];
	
	// Check to make sure every column has a name.  Remove any column from our export that doesn't have a name set.
	var namelessColumns = [CPMutableArray array];
	for (var index = 0; index < [orderedColumns count]; index++) {
		if ([[column name] length] == 0) {
			[namelessColumns addObject:column];
		}
	}
	[orderedColumns removeObjectsInArray:namelessColumns];
	
	// Now we have an ordered array of columns that have names associated with them.
	var orderedColumnCount = [orderedColumns count];
	
	// Generate the first row, which are the column names (both original and modified group names).
	var /* CPArray[CPString] */ firstRow = [CPMutableArray array];
	for (var index = 0; index < orderedColumnCount; index++) {
		var /* CMColumn */ column = orderedColumns[index];
		[firstRow addObject:[column name]];
		[firstRow addObject:[column groupName] ? [column groupName] : [column name]];
		
		// Find our max value count.
		var columnOriginalValueCount = [[column originalValues] count];
		var columnModifiedValueCount = [[column modifiedValues] count];
		if (columnOriginalValueCount > maxValueCount) maxValueCount = columnOriginalValueCount;
		if (columnModifiedValueCount > maxValueCount) maxValueCount = columnModifiedValueCount;
	}
	[lines addObject:firstRow];
	
	// Print the second row, which marks which spreadsheet the column is from.
	var /* CPArray[CPString] */ secondRow = [CPMutableArray array];
	for (var index = 0; index < orderedColumnCount; index++) {
		var /* CMColumn */ column = orderedColumns[index];
		[secondRow addObject:[column spreadsheetName] ? [column spreadsheetName] : @""];
		[secondRow addObject:@""];
	}
	[lines addObject:secondRow];

	// Now append the value rows.
	for (var valueIndex = 0; valueIndex < maxValueCount; valueIndex++) {
		var /* CPArray[CPString] */ line = [CPMutableArray array];
		for (var columnIndex = 0; columnIndex < orderedColumnCount; columnIndex++) {
			var /* CMColumn */ column = orderedColumns[index];
			var /* CPArray[CPString] */ originalValues = [column originalValues];
			var /* CPArray[CPString] */ modifiedValues = [column modifiedValues];
			
			if (valueIndex < [originalValues count]) {
				[line addObject:originalValues[valueIndex]];
			}
			else {
				[line addObject:@""];
			}
			
			if (valueIndex < [modifiedValues count]) {
				[line addObject:modifiedValues[valueIndex]];
			}
			else {
				[line addObject:@""];
			}
		}
	}
	
	var csv = [[CMCSV alloc] init];
	[csv setLines:lines];
	return csv;
}

@end
