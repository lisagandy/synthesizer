/*
 * CMMainView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CMMainItemView.j"
@import "../Model/CMColumnManager.j"
@import "../Base/CMScroller.j"
@import "CMValueEditingView.j"

@implementation CMMainView : CPView
{
	CPScrollView scrollView;
	CPTableView tableView;
	CMValueEditingView valueEditor;
		
	CMColumnGroup selectedGroup;
	
	// Text typed into the search box that we should use to filter the columns.
	CPString textFilter @accessors;
	
	// The last array of CMColumn objects sent to the content of the collection view.  Used when dragging.
	CPArray latestContent;
	
	CMMainItemView itemTemplate;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		scrollView = [[CPScrollView alloc] initWithFrame:[self bounds]];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setHasHorizontalScroller:NO];
		[scrollView setHasVerticalScroller:YES];
				
		tableView = [[CPTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[tableView setRowHeight:44];
		[tableView setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
		[tableView setHeaderView:nil];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView setTarget:self];
		[tableView setDoubleAction:@selector(rowDoubleClicked:)];
		[tableView setSelectionHighlightColor:[CPColor colorWithWhite:0.9 alpha:1]];
		tableView._unfocusedSelectionHighlightColor = [CPColor colorWithWhite:0.9 alpha:1];
/*
		[tableView setSelectionHighlightColor:[CPColor colorWithHue:0.597 saturation:0.666 brightness:0.83 alpha:1]];
		tableView._unfocusedSelectionHighlightColor = [CPColor colorWithHue:0.597 saturation:0.666 brightness:0.83 alpha:1];
*/
/*
		[tableView setSelectionGradientColors:@{ CPSourceListTopLineColor: [CPColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1],
			                                     CPSourceListBottomLineColor: [CPColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1],
			                                     CPSourceListGradient : CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [ [CPColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1], [CPColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1] ], 0) }];
*/
		[tableView registerForDraggedTypes:[ "CMColumnDragItemType" ]];		

		var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Column 1"];
		[tableColumn setWidth:[self bounds].size.width];
		[tableView addTableColumn:tableColumn];

		[scrollView setDocumentView:tableView];
		[self addSubview:scrollView];

		itemTemplate = [[CMMainItemView alloc] initWithFrame:CGRectMake(0, 0, 300, 34)];

		latestContent = [CPArray array];
		selectedGroup = nil;
		[self updateContent];
	} 
	return self;
}

- (void)setTextFilter:(CPString)aFilter {
	textFilter = [aFilter lowercaseString];
	[self updateContent];
}

- (void)updateContent {
	var contentArray = [CPArray array];
	if (!selectedGroup) {
		contentArray = [[CMColumnManager sharedManager] columns];
	}
	else {
		var members = [[CMColumnManager sharedManager] columnsInGroup:selectedGroup];
		if (members) contentArray = members;
	}
	
	// Apply the text filter.
	if ([textFilter length]) {
		var filteredItems = [CPMutableArray array];
		for (var i = 0; i < [contentArray count]; i++) {
			var /* CMColumn */ column = [contentArray objectAtIndex:i];
			if ([column matchesFilter:textFilter]) {
				[filteredItems addObject:column]; 
			}
		}
		
		contentArray = filteredItems;
	}
	
	latestContent = contentArray;
	[tableView reloadData];
}

- (void)setSelectedGroup:(CMColumnGroup)aGroup {
	selectedGroup = aGroup;
	[self updateContent];
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView {
    return [latestContent count];
}

- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex {
	var copy = [CPKeyedArchiver archivedDataWithRootObject:itemTemplate];
	return [CPKeyedUnarchiver unarchiveObjectWithData:copy];
}

- (void)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumnu row:(int)aRow {
    return latestContent[aRow];
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification {
/*
	var selectedIndex = [tableView selectedRow];
	
	if (selectedIndex < [content count]) {
		[mainView setSelectedGroup:[content objectAtIndex:selectedIndex]];
	}
*/
}

- (void)tableView:(CPTableView)aTableView willDisplayView:(CPView)aView forTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex {
	[aView setSelected:(aRowIndex == [aTableView selectedRow])];
}

- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pasteboard {
    var encodedData = [CPKeyedArchiver archivedDataWithRootObject:[latestContent objectAtIndex:[rowIndexes firstIndex]]];
    [pasteboard declareTypes:[CPArray arrayWithObject:"CMColumnDragItemType"] owner:self];
    [pasteboard setData:encodedData forType:"CMColumnDragItemType"];

    return YES;
}

- (void)rowDoubleClicked:(id)sender {
	var /* CMColumn */ columnClicked = nil;
	if ([self.tableView clickedRow] < [latestContent count]) {
		columnClicked = latestContent[[tableView clickedRow]];
	}
	
	if (columnClicked) [self openValueEditor:columnClicked];
}

- (void)openValueEditor:(CMColumn)editingColumn {
	if (!valueEditor) {
		valueEditor = [[CMValueEditingView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
		[valueEditor setMainView:self];
		[valueEditor setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin | CPViewHeightSizable];
	}
	
	var /* CPView */ sv = [self superview];
	var /* CGRect */ svBounds = [sv bounds];
	
	var /* CGSize */ editorSize = CGSizeMake(MIN(500, svBounds.size.width - 100), MIN(700, svBounds.size.height - 100));
	
	[valueEditor setFrame:CGRectMake((svBounds.size.width - editorSize.width) * 0.5, (svBounds.size.height - editorSize.height) * 0.5, editorSize.width, editorSize.height)];
	
	[valueEditor setEditingColumn:latestContent[[tableView clickedRow]]];
	[sv addSubview:valueEditor];
}

- (void)closeValueEditor {
	if (valueEditor) {
		[valueEditor removeFromSuperview];
	}
}

/*
- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	CGContextSetFillColor(context, [CPColor yellowColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x + 5, bounds.origin.y + 5, bounds.size.width - 10., bounds.size.height - 10.)); 
}
*/

@end
