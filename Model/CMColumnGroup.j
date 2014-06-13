/*
 * CMColumnGroup.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 30, 2014.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CMColumnManager.j"

@implementation CMColumnGroup : CPObject
{
	// The column name.
	CPString name @accessors;
	
	// If YES, then this pseudo-group is for showing all source spreadsheet columns.
	BOOL allGroup @accessors;
	
	// If YES, then this pseudo-group is for showing all source spreadsheet columns not in another group.
	BOOL soloGroup @accessors;
}

- (void)initWithName:(CPString)n {
	self = [super init];
	if (self) {
		name = n;
	}
	return self;
}

- (CPString)description {
	return [CPString stringWithFormat:@"CMColumnGroup (%@)", name ? name : @""];
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
