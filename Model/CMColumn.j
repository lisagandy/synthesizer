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
	
	// An array of CMColumn objects that are equivalent to this column.  
	CPArray equivalentColumns @accessors;
	
	// If YES, this is the "special" derived column that should show all source columns.
	BOOL allColumn @accessors;
}

- (void)initWithName:(CPString)n {
	self = [super init];
	if (self) {
		name = n;
	}
	return self;
}

@end
