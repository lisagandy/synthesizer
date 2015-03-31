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

- (CMColumnGroup)allGroup {
	var /* CMColumnGroup */ retColumnGroup = nil;
	
	for (var i = 0; i < [columnGroups count]; i++) {
		var group = [columnGroups objectAtIndex:i];
		if ([group allGroup]) {
			retColumnGroup = group;
			break;
		}
	}

	return retColumnGroup;	
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

/* Returns a list of spreadsheet names from the column values. */
- (CPArray)spreadsheetNames {
	// Reduce into a CPSet object, where duplicates will be ignored.
	var names = [[CPMutableSet alloc] init];
	for (var i = 0; i < [columns count]; i++) {
		var columnSpreadsheet = [[columns objectAtIndex:i] spreadsheet];
		if (columnSpreadsheet != nil) [names addObject:columnSpreadsheet];
	}
	
	return [names allObjects];
}

/* Returns the total number of rows in a specified spreadsheet. */
- (CPInteger)rowsInSpreadsheet:(CPString)spreadsheetName {
	var /* CPInteger */ maxRows = 0;
	for (var i = 0; i < [columns count]; i++) {
		var /* CMColumn */ column = [columns objectAtIndex:i];
		if ([[column spreadsheet] isEqualToString:spreadsheetName]) {
			var thisColumnRowCount = [[column originalValues] count];
			if (thisColumnRowCount > maxRows) {
				maxRows = thisColumnRowCount;
			}
		}
	}	
	
	return maxRows;
}

// This method will search for a string in all of the spreadsheet data and return an array of CMColumn objects that match.  This method will only search for the modified values (or original values for rows that haven't been modified).
- (CPArray)columnsWithValuesMatchingString:(CPString)valueSearchString {
	var matchingColumns = [CPMutableArray array];

	for (var columnIndex = 0; columnIndex < [columns count]; columnIndex++) {
		var /* CMColumn */ column = [columns objectAtIndex:columnIndex];
		
		if ([column matchesValueSearchString:valueSearchString]) {
			[matchingColumns addObject:column];
		}
	}

	return matchingColumns;	
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
	if ([valueArrays count] >= 2) {
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

	// Create the column order.  The orderedColumn array will have CMColumnGroup objects first, then solo CMColumn objects at the end.
	var orderedColumns = [CPMutableArray array];
	for (var groupIndex = 0; groupIndex < [columnGroups count]; groupIndex++) {
		var /* CMColumnGroup */ group = [columnGroups objectAtIndex:groupIndex];
		if ([group soloGroup]) continue;
		if ([group allGroup]) continue;
		if (group) [orderedColumns addObject:group];
	}
	var /* CPArray[CMColumn] */ solo = [self soloColumns];
	if (solo) [orderedColumns addObjectsFromArray:solo];
	
	// Check to make sure every column has a name.  Remove any column from our export that doesn't have a name set.
	var namelessColumns = [CPMutableArray array];
	for (var index = 0; index < [orderedColumns count]; index++) {
		var /* CMColumn or CMColumnGroup */ columnOrGroup = [orderedColumns objectAtIndex:index];
		if ([[self nameOfColumnOrGroup:columnOrGroup] length] == 0) {
			[namelessColumns addObject:columnOrGroup];
		}
	}
	[orderedColumns removeObjectsInArray:namelessColumns];
	
	// Now we have an ordered array of columns that have names associated with them.
	var orderedColumnCount = [orderedColumns count];
	
	// Generate the first row, which include the spreadsheet name in the first column followed by the additional column names.
	var /* CPArray[CPString] */ firstRow = [CPMutableArray array];
	[firstRow addObject:@"Spreadsheet Name"];
	for (var index = 0; index < orderedColumnCount; index++) {
		var /* CMColumn or CMColumnGroup */ columnOrGroup = [orderedColumns objectAtIndex:index];
		var /* CPString */ columnOrGroupName = [self nameOfColumnOrGroup:columnOrGroup];
		
		[firstRow addObject:columnOrGroupName];
	}
	[lines addObject:firstRow];
	
	// Get a list of spreadsheets.
	var /* CPArray */ spreadsheets = [self spreadsheetNames];
	
	// For each spreadsheet, get an array of values.
	for (var spreadsheetIndex = 0; spreadsheetIndex < [spreadsheets count]; spreadsheetIndex++) {
		var /* CPString */ spreadsheetName = [spreadsheets objectAtIndex:spreadsheetIndex];
		if (!spreadsheetName) continue;
		
		var /* CPArray */ spreadsheetRows = [self valuesForSpreadsheet:spreadsheetName columnOrGroupOrder:orderedColumns];
		for (var row = 0; row < [spreadsheetRows count]; row++) {
			// Append this row to our output.
			var /* CPArray[CPString] */ line = [CPMutableArray array];
			
			// Add the spreadsheet name as the first column.
			[line addObject:spreadsheetName];
			
			// Now add the rest of the columns.
			[line addObjectsFromArray:[spreadsheetRows objectAtIndex:row]];
			
			// Finally append it to our lines array.
			[lines addObject:line];
		}
	}
	
	// Finally, use our generated lines to create a CSV file.	
	var csv = [[CMCSV alloc] init];
	[csv setLines:lines];
	return csv;
}

- (CPString)nameOfColumnOrGroup:(CPString)columnOrGroup {
		// Get the column name.  Notice that the same "name" method is called for either type of object, but still define separate branches to be more explicit with the data we are using. 		
		if ([columnOrGroup isKindOfClass:[CMColumn class]]) {
			return [columnOrGroup name];
		}
		else if ([columnOrGroup isKindOfClass:[CMColumnGroup class]]) {
			return [columnOrGroup name];
		}
		else {
			return @"";
		}
}

/* This is a workhorse method.  We could have integrated it into exportCSV because that is the only place it is used, but it makes the code easier to maintain if we split it out. */
- (CPArray)valuesForSpreadsheet:(CPString)spreadsheetName columnOrGroupOrder:(CPArray)orderedColumns {
	// First find out how many rows we should be generating.
	var /* CPInteger */ spreadsheetRows = [self rowsInSpreadsheet:spreadsheetName];

	var lines = [CPMutableArray array];

	for (var row = 0; row < spreadsheetRows; row++) {
		var line = [CPMutableArray array];
		
		for (var col = 0; col < [orderedColumns count]; col++) {
			var columnValue = @"";
			
			var /* CMColumn or CMColumnGroup */ columnOrGroup = [orderedColumns objectAtIndex:col];
			if ([columnOrGroup isKindOfClass:[CMColumn class]]) {			
				if ([[columnOrGroup spreadsheet] isEqualToString:spreadsheetName]) {
					// This is a column in our spreadsheet.  Get the final values for it.
					var /* CPArray */ finalValues = [columnOrGroup finalValues];
					if (row < [finalValues count]) {
						columnValue = [finalValues objectAtIndex:row];
					}
				}
			}
			else if ([columnOrGroup isKindOfClass:[CMColumnGroup class]]) {
				// Get the column in this group that corresponds to our spreadsheet.
				var /* CPArray[CMGroup] */ groupColumns = [self columnsInGroup:columnOrGroup];
				for (var i = 0; i < [groupColumns count]; i++) {
					var /* CMColumn */ groupColumn = [groupColumns objectAtIndex:i];
					if ([[groupColumn spreadsheet] isEqualToString:spreadsheetName]) {
						// This is a column in our spreadsheet.  Get the final values for it.
						var /* CPArray */ finalValues = [groupColumn finalValues];
						if (row < [finalValues count]) {
							columnValue = [finalValues objectAtIndex:row];
						}
					}
				}
			}
			
			[line addObject:columnValue];
		}
		
		[lines addObject:line];
	}
	
	return lines;
}

@end
