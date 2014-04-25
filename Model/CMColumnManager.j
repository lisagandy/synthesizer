/*
 * CMColumnManager.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 25, 2014.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

var CMColumnManager_sharedManager = nil;

@implementation CMColumnManager : CPObject
{
	// An array of CMColumn objects.  These show up in the sidebar.
	CPArray derivedColumns @accessors;
	
	// An array of CMColumn objects.  These are all the columns present in source spreadsheets.
	CPArray sourceColumns @accessors;
}

+ (CMColumnManager)sharedManager {
	if (!CMColumnManager_sharedManager) CMColumnManager_sharedManager = [[CMColumnManager alloc] init];
	return CMColumnManager_sharedManager;
}

- (CPArray)equivalentsForColumn:(CMColumn)column {
	if (column == nil) return sourceColumns;
	if ([column allColumn]) return sourceColumns;

	return [column equivalentColumns];
}

@end
