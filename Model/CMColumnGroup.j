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
	
	// An array of CMColumn objects that are members of this group.  
	CPArray members @accessors;
	
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

- (CPArray)members {
	if (allGroup) {
		return [[CMColumnManager sharedManager] columns];
	}
	else if (soloGroup) {
		return [[CMColumnManager sharedManager] soloColumns];
	}
	else {
		if ([members count]) return members;
		else return [CPArray array];
	}
}

@end
