/*
 * CMColumn.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 25, 2014.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMColumn : CPObject
{
	// The column name.
	CPString name @accessors;
	
	// The column source spreadsheet.
	CPString spreadsheet @accessors;
	
	// A combined lowercase string for search purposes.
	CPString searchString;
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

- (void)updateSearchString {
	searchString = [[CPString stringWithFormat:@"%@ %@", name ? name : @"", spreadsheet ? spreadsheet : @""] lowercaseString];
}

- (CPString)description {
	return [CPString stringWithFormat:@"CMColumn {\n    Name: %@\n    Spreadsheet: %@\n}", name ? name : @"", spreadsheet ? spreadsheet : @""];
}

- (BOOL)isEqualToColumn:(CMColumn)otherColumn {
	return [name isEqualToString:[otherColumn name]] && [spreadsheet isEqualToString:[otherColumn spreadsheet]];
}

- (CPComparisonResult)compare:(id)otherObject {
	if ([otherObject isKindOfClass:[self class]]) {
		return [name caseInsensitiveCompare:[otherObject name]];	
	}
	else {
		return CPOrderedSame;
	}
}

- (BOOL)matchesFilter:(CPString)filter {
	// Assumes filter is already lowercase.
	return ([searchString rangeOfString:filter].location != CPNotFound);
}

@end
