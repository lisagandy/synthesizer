/*
 * CMColumn.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 *
 * A CMColumn object represents a column from one of the source spreadsheets.  
 * The object also stores the original and modified values of the column, as 
 * well as a reference to the group the column belongs to.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CMColumnGroup.j"

@implementation CMColumn : CPObject
{
	// The column name.
	CPString name @accessors;
	
	// The column source spreadsheet.
	CPString spreadsheet @accessors;
	
	// The original values array for this column in the source spreadsheet.
	CPArray originalValues @accessors;
	
	// The modified values array for this column after equalizing the data between different spreadsheets.
	CPArray modifiedValues @accessors;
	
	// This is a cached array generated by finalValues.  If originalValues or modifiedValues changes, then this should be cleared and regenerated.
	CPArray cachedFinalValues;
	
	// A combined lowercase string for search purposes.
	CPString searchString;
	
	CMColumnGroup group @accessors;
}

- (void)initWithName:(CPString)n spreadsheet:(CPString)s {
	self = [super init];
	if (self) {
		name = n;
		spreadsheet = s;
		[self updateSearchString];
	}
	return self;
}

- (id)initWithCoder:(CPCoder)aCoder {
	self = [super init];
	if (self) {
		name = [aCoder decodeObjectForKey:@"CMColumn Name"];
		spreadsheet = [aCoder decodeObjectForKey:@"CMColumn Spreadsheet"];
		[self updateSearchString];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder {
	[aCoder encodeObject:name forKey:@"CMColumn Name"];
	[aCoder encodeObject:spreadsheet forKey:@"CMColumn Spreadsheet"];
}

- (void)setName:(CPString)aString {
	name = aString;
	[self updateSearchString];
}

- (void)setSpreadsheet:(CPString)aString {
	spreadsheet = aString;
	[self updateSearchString];
}

- (void)setOriginalValues:(CPArray)anArray {
	originalValues = anArray;
	cachedFinalValues = nil;
}

- (void)setModifiedValues:(CPArray)anArray {
	modifiedValues = anArray;
	cachedFinalValues = nil;
}

- (void)updateSearchString {
	searchString = [[CPString stringWithFormat:@"%@ %@", name ? name : @"", spreadsheet ? spreadsheet : @""] lowercaseString];
}

- (CPString)combinedName {
	return [CPString stringWithFormat:@"%@ (%@)", name ? name : @"", spreadsheet ? spreadsheet : @""];
}

- (CPString)description {
	return [CPString stringWithFormat:@"CMColumn {\n    Name: %@\n    Spreadsheet: %@\n    Values: (%d, %d)\n}", name ? name : @"", spreadsheet ? spreadsheet : @"", [originalValues count], [modifiedValues count]];
}

/* This method will use modified values if they exist.  For every row with an empty value, the original value will be used instead. */
- (CPArray)finalValues {
	if (cachedFinalValues) {
		return cachedFinalValues;
	}

	var /* CPMutableArray */ finalArray = [CPMutableArray array];
	for (var i = 0; i < [originalValues count]; i++) {
		var /* CPString */ rowValue = [self valueForRow:i];
		[finalArray addObject:rowValue];
	}
	
	cachedFinalValues = finalArray;
	return finalArray;
}

- (BOOL)isEqualToColumn:(CMColumn)otherColumn {
	return ([name caseInsensitiveCompare:[otherColumn name]] == CPOrderedSame) && ([spreadsheet caseInsensitiveCompare:[otherColumn spreadsheet]] == CPOrderedSame);
}

- (CPComparisonResult)compare:(id)otherObject {
	if ([otherObject isKindOfClass:[self class]]) {
		var nameComparison = [name caseInsensitiveCompare:[otherObject name]];
		if (nameComparison == CPOrderedSame) {
			return [spreadsheet caseInsensitiveCompare:[otherObject spreadsheet]];
		}
		else {
			return nameComparison;
		}
	}
	else {
		return CPOrderedSame;
	}
}

// This is to filter the columns by column name.
- (BOOL)matchesFilter:(CPString)filter {
	// Assumes filter is already lowercase.
	return ([searchString rangeOfString:filter].location != CPNotFound);
}

// Return YES if the search string is present in our originalValues or modifiedValues.
- (BOOL)matchesValueSearchString:(CPString)valueSearchString {
	// Check the original values.
	for (var i = 0; i < [originalValues count]; i++) {
		if ([[originalValues objectAtIndex:i] isEqualToString:valueSearchString]) {
			return YES;
		}
	}
	
	// Check the modified values.
	for (var i = 0; i < [modifiedValues count]; i++) {
		if ([[modifiedValues objectAtIndex:i] isEqualToString:valueSearchString]) {
			return YES;
		}
	}

	return NO;
}

// Loops through the values and replaces any value matching searchString with replacementString.  Returns the number of occurances replaced.
- (int)replaceValue:(CPString)valueSearchString withValue:(CPString)replacementString {
	var numReplacements = 0;
	
	for (var i = 0; i < [originalValues count]; i++) {
		var replaceRow = false;
		// Check if the original value matches the valueSearchString.
		if ([[originalValues objectAtIndex:i] isEqualToString:valueSearchString]) {
			replaceRow = true;
		}
		
		// Check if the modified value matches the valueSearchString.
		if (i < [modifiedValues count]) {
			if ([[modifiedValues objectAtIndex:i] isEqualToString:valueSearchString]) {
				replaceRow = true;
			}
		}
		
		// If we have a match, replace the value.
		if (replaceRow) {
			[self saveModifiedValue:replacementString forRow:i]
			numReplacements++;
		}
	}
	
	return numReplacements;
}

// Will check a given row in the spreadsheet.  If a modified value exists, it is returned.  Otherwise the original value is returned.
- (CPString)valueForRow:(int)row {
	var /* CPString */ rowValue = @"";
	if (row < [modifiedValues count]) {
		// Try to read the modified value first.
		rowValue = [modifiedValues objectAtIndex:row];
	}
	if (([rowValue length] == 0) && (row < [originalValues count])) {
		// If the modified value was empty, then use the original value for this row.
		rowValue = [originalValues objectAtIndex:row];
	}
	return rowValue;
}

// The modified value array might not have enough elements, so we have to make sure we pad the array with empty elements before saving the modified value.
- (CPString)saveModifiedValue:(CPString)modifiedValue forRow:(int)row {
	var updatedModifiedValues = [CPMutableArray array];
	if (modifiedValues) [updatedModifiedValues addObjectsFromArray:modifiedValues];
	
	while ([updatedModifiedValues count] < row + 1) {
		[updatedModifiedValues addObject:@""];
	}
	
	[updatedModifiedValues replaceObjectAtIndex:row withObject:modifiedValue];
	[self setModifiedValues:updatedModifiedValues];
}

@end
