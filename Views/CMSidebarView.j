/*
 * CMSidebarView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CMSidebarItemView.j"
@import "../Model/CMColumnManager.j"
@import "CMMainView.j"

@implementation CMSidebarView : CPView
{
	CGPoint originalClickInWindow;
	CGRect originalFrame;
	
	CPScrollView scrollView;
	CPTableView tableView @accessors;
	
	CPMainView mainView @accessors;
	
	CPArray content;
	CMSidebarItemView itemTemplate;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		scrollView = [[CPScrollView alloc] initWithFrame:[self bounds]];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setAutohidesScrollers:NO];
		[scrollView setHasHorizontalScroller:NO];
		
		tableView = [[CPTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[tableView setRowHeight:34];
		[tableView setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
		[tableView setHeaderView:nil];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView setSelectionHighlightColor:nil];
		[tableView setSelectionGradientColors:@{ CPSourceListTopLineColor: [CPColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1],
			                                     CPSourceListBottomLineColor: [CPColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1],
			                                     CPSourceListGradient : CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [ [CPColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1], [CPColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1] ], 0) }];
		[tableView registerForDraggedTypes:[ "CMColumnDragItemType" ]];		

		var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Column 1"];
		[tableColumn setWidth:[self bounds].size.width];
		[tableView addTableColumn:tableColumn];

		[scrollView setDocumentView:tableView];
		[self addSubview:scrollView];

		itemTemplate = [[CMSidebarItemView alloc] initWithFrame:CGRectMake(0, 0, 300, 34)];

		content = [CPArray array];
		[self updateContent];
	}
	return self;
}

- (void)updateContent {
	content = [[CMColumnManager sharedManager] columnGroups];
	
	var selectedIndex = [tableView selectedRow];
	if (selectedIndex == -1) selectedIndex = 0;
	
	if (selectedIndex < [content count]) {
		[mainView setSelectedGroup:[content objectAtIndex:selectedIndex]];
	}
	
	[tableView reloadData];
	if (selectedIndex == 0) {
		if ([content count]) {
			[tableView selectRowIndexes:[CPIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		}
	}
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView {
    return [content count];
}

- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex {
	var copy = [CPKeyedArchiver archivedDataWithRootObject:itemTemplate];
	return [CPKeyedUnarchiver unarchiveObjectWithData:copy];
}

- (void)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumnu row:(int)aRow {
    return content[aRow];
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification {
	var selectedIndex = [tableView selectedRow];
	
	if ((selectedIndex >= 0) && (selectedIndex < [content count])) {
		[mainView setSelectedGroup:[content objectAtIndex:selectedIndex]];
	}
	else {
		[tableView selectRowIndexes:[CPIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	}
}

- (void)tableView:(CPTableView)aTableView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex {
	[aView setSelected:(aRowIndex == [aTableView selectedRow])];
}

- (BOOL)tableView:(CPTableView)aTableView acceptDrop:(id)draggingInfo row:(CPInteger)aRowIndex dropOperation:(CPTableViewDropOperation)anOperation {
	if (anOperation == CPTableViewDropOn) {
		var /* CMColumnGroup */ group = [content objectAtIndex:aRowIndex];
		if ([group allGroup]) group = nil;		// If dragged to the All group, then remove it from any other group.
		if ([group soloGroup]) group = nil;		// If dragged to the Solo group, then remove it from any other group.
	
	    var /* CPData */ data = [[draggingInfo draggingPasteboard] dataForType:@"CMColumnDragItemType"];
		var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];
		
		[[[CMColumnManager sharedManager] columnMatchingExternalColumn:column] setGroup:group];
		[tableView reloadData];
		[self updateContent];
	}
}

- (CPDragOperation)tableView:(CPTableView)aTableView validateDrop:(id)draggingInfo proposedRow:(CPInteger)aRowIndex proposedDropOperation:(CPTableViewDropOperation)anOperation {
	if (anOperation == CPTableViewDropAbove) return CPDragOperationNone;

    var /* CPData */ data = [[draggingInfo draggingPasteboard] dataForType:@"CMColumnDragItemType"];
	var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];

	if (column) {
		return CPDragOperationCopy;
	}
	
	return CPDragOperationNone;
}

- (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex {
	console.log("Should edit: " + rowIndex);
}

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(void)context {
	if (object == tableView) {
		if ([keyPath isEqualToString:@"selectedRowIndexes"]) {
			var selectedIndex = [tableView selectedRow];
			
			if (selectedIndex < [content count]) {
				[mainView setSelectedGroup:[content objectAtIndex:selectedIndex]];
			}
		}
	}
}

@end
