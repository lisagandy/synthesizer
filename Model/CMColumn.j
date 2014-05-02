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
}

- (void)initWithName:(CPString)n spreadsheet:(CPString)s {
	self = [super init];
	if (self) {
		name = n;
		spreadsheet = s;
	}
	return self;
}

- (CPString)description {
	return [CPString stringWithFormat:@"CMColumn {\n    Name: %@\n    Spreadsheet: %@\n}", name ? name : @"", spreadsheet ? spreadsheet : @""];
}

- (CPComparisonResult)compare:(id)otherObject {
	if ([otherObject isKindOfClass:[self class]]) {
		return [name caseInsensitiveCompare:[otherObject name]];	
	}
	else {
		return CPOrderedSame;
	}
}

@end
