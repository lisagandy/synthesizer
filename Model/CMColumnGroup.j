/*
 * CMColumnGroup.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 *
 * This object tracks a column group.  It's a pretty short implementation with just
 * a name and a few flags to mark whether it is the "solo" group or the "all" group.  
 * Since columns can only be in a single group, the CMColumn object actually keeps 
 * track of which group it belongs to as opposed to the CMColumnGroup keeping an array 
 * of its members.  The CMColumnManager can be used when you want to find out which
 * columns are a member of a certain group.
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
