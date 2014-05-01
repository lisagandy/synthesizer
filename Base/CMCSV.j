/*
 * CMCSV.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 30, 2014.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 *
 * This class will parse a CSV file exported from Excel.  The delimiters are commas (,).  
 * Fields that contain a comma are surrounded by double-quotes (").  
 * Fields that contain a double-quote are also surrounded by double-quotes.
 * The results are placed in the CPArray lines object.  Values are CPArray objects with each column parsed out.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMCSV : CPObject
{
	// An array of arrays.  The second level arrays are columns for each line.
	CPArray lines;
}

- (id)initWithCSVText:(CPString)csv {
	self = [super init];
	if (self) {
		[self parse:csv];
	}
	return self;
}

- (void)parse:(CPString)csv {
	// The cell value...
	// "foo", "goo", "" ,,
	// becomes...
	// """foo"", ""goo"" """" ,,"
	// 
	// The cell value...
	// "foo"
	// becomes...
	// """foo"""
	
	var parsedLines = [CPMutableArray array];

	var /* CPArray */ csvLines = [csv componentsSeparatedByString:@"\n"];
	
	for (var lineNumber = 0; lineNumber < [csvLines count]; lineNumber++) {
		// Iterate through the CSV lines.
		var currentLine = [CPMutableArray array];
		var currentColumn = @"";

		var /* CPString */ csvLine = [csvLines objectAtIndex:lineNumber];
		var inQuote = NO;
		
		var characterIndex = 0;
		while (characterIndex < [csvLine length]) {
			// Iterate through the characters on each line.
			var /* CPString */ thisCharacter = [csvLine characterAtIndex:characterIndex];
			
			if (inQuote) {
				if ([thisCharacter isEqualToString:@"\""]) {
					// Check if the following character is a quote.
					var nextCharacter = (characterIndex < [csvLine length] - 1) ? [csvLine characterAtIndex:characterIndex + 1] : @"";
					
					if ([nextCharacter isEqualToString:@"\""]) {
						// Two double-quotes (""), replace with a single double-quote (") and continue on in the same column.
						currentColumn = [currentColumn stringByAppendingString:@"\""];
						// Increment the characterIndex an extra stop, to skip the second ".
						characterIndex++;
					}
					else {
						// One double-quote, this is the end of a column, set inQuote = NO.
						inQuote = NO;
					}
				}
				else {
					// Append character to the current column.
					currentColumn = [currentColumn stringByAppendingString:thisCharacter];
				}
			}
			else {
				if ([thisCharacter isEqualToString:@"\""]) {
					// Start a quoted column.
					inQuote = YES;
				}
				else if ([thisCharacter isEqualToString:@","]) {
					// Save and start a new column.
					[currentLine addObject:currentColumn];
					currentColumn = @"";
				}
				else {
					// Append character to the current column.
					currentColumn = [currentColumn stringByAppendingString:thisCharacter];
				}
			}
			
			characterIndex++;
		}
		
		// Check to make sure we are in an expected state.  If we are in a quote, then our line was malformed.
		if (inQuote) {
			console.log("[CMCSV parse] Failed to parse line " + lineNumber + ".  Line text(" + csvLine + ")");
		}
		else {
			// Line was parsed successfully.  Save it.
			
			// At the end of each line, add the last column.
			if ([currentColumn length]) {
				[currentLine addObject:currentColumn];
			}
			else {
				// Check if we need to add an empty column.
				if ([csvLine hasSuffix:@","]) {
					[currentLine addObject:@""];
				}
			}
			
			// Finally, add the currentLine to our parsedLines.
			[parsedLines addObject:currentLine];
		}
	}
	
	lines = parsedLines;
}

- (CPArray)dictionaryArray {
	// Return an array of CPDictionary objects.  The first parsed line is used for the dictionary keys, and the following lines are the values.
	// First check for at least 2 lines.
	if ([lines count] < 2) return [CPArray array];
	
	var /* CPArray */ columnNames = [lines objectAtIndex:0];
	var columnNameCount = [columnNames count];
	
	var retArray = [CPMutableArray array];
	
	for (var lineIndex = 1; lineIndex < [lines count]; lineIndex++) {
		var /* CPArray */ columns = [lines objectAtIndex:lineIndex];
		var columnCount = [columns count];
		
		if (columnNameCount != columnCount) {
			// Mismatch in the number of column names and the number of columns in this line.  Log it and then continue to convert what we can.
			console.log("[CMCSV dictionaryArray] Column count mismatch (" + columnNameCount + ", " + columnCount + ").  Converting as much as we can.");
		}
		
		var lineDictionary = [CPMutableDictionary dictionary];
		for (var columnIndex = 0; (columnIndex < columnNameCount) && (columnIndex < columnCount); columnIndex++) {
			[lineDictionary setObject:[columns objectAtIndex:columnIndex] forKey:[columnNames objectAtIndex:columnIndex]];
		}
		[retArray addObject:lineDictionary];
	}
	
	return retArray;
}

@end


