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

@implementation CMMainView : CPView
{
	CPScrollView scrollView;
	//CPCollectionView collectionView;
	CPTableView tableView;
	
	CGSize minItemSize;
	
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
		minItemSize = CGSizeMake(150, 50);
	
		scrollView = [[CPScrollView alloc] initWithFrame:[self bounds]];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setHasHorizontalScroller:NO];
		[scrollView setHasVerticalScroller:YES];
/* 		[scrollView setAutohidesScrollers:NO]; */
/* 		[scrollView setVerticalScroller:[[CMScroller alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]]; */
/* 		[[scrollView verticalScroller] setAllowFadingOut:NO]; */
/* 		[scrollView setScrollerStyle:CPScrollerStyleLegacy]; */
		
/*
		collectionView = [[CPCollectionView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[collectionView setMinItemSize:CGSizeMake(150, 44)];
 		[collectionView setMaxItemSize:CGSizeMake(5000, 44)];
		[collectionView setMaxNumberOfColumns:1];
		[collectionView setMaxNumberOfRows:5000];
		[collectionView setAllowsEmptySelection:NO];
		[collectionView setAllowsMultipleSelection:NO];
		[collectionView setVerticalMargin:1.];
		[collectionView setBackgroundColor:[CPColor colorWithHexString:@"dce0e2"]];  // between this and the 1px vertical margin, we get line separators.
		[collectionView setDelegate:self];
		[collectionView addObserver:self forKeyPath:@"selectionIndexes" options:(CPKeyValueObservingOptionNew) context:NULL];
		
		var itemPrototype = [[CPCollectionViewItem alloc] init];
		[itemPrototype setView:[[CMMainItemView alloc] initWithFrame:CGRectMakeZero()]];
		[collectionView setItemPrototype:itemPrototype];

		[scrollView setDocumentView:collectionView];
		[self addSubview:scrollView];
*/
		
		tableView = [[CPTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[tableView setRowHeight:44];
		[tableView setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
		[tableView setHeaderView:nil];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
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

/*
- (void)setFrame:(CGRect)aFrame {
	[super setFrame:aFrame];
	[self configureCollectionViewSize];
}
*/

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
	//[collectionView setContent:contentArray];
	[tableView reloadData];
}

/*
- (void)configureCollectionViewSize {
	// Every time our view size changes, we need to call this again so we can configure how the collection view is displayed.
	var bounds = [self bounds];
	
	// Calculate the max number of items we can fit on screen using minItemSize.
	var numRows = FLOOR(bounds.size.height / minItemSize);
	[collectionView setMaxNumberOfRows:numRows];
}
*/

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


// - (BOOL)tableView:(CPTableView)aTableView acceptDrop:(id)draggingInfo row:(CPInteger)aRowIndex dropOperation:(CPTableViewDropOperation)anOperation {
// 	if (anOperation == CPTableViewDropOn) {
// 		var /* CMColumnGroup */ group = [content objectAtIndex:aRowIndex];
// 		if ([group allGroup]) group = nil;		// If dragged to the All group, then remove it from any other group.
// 		if ([group soloGroup]) group = nil;		// If dragged to the Solo group, then remove it from any other group.
// 	
// 	    var /* CPData */ data = [[draggingInfo draggingPasteboard] dataForType:@"CMColumnDragItemType"];
// 		var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];
// 		
// 		[[[CMColumnManager sharedManager] columnMatchingExternalColumn:column] setGroup:group];
// 		[tableView reloadData];
// 		[self updateContent];
// 	}
// }
// 
// - (CPDragOperation)tableView:(CPTableView)aTableView validateDrop:(id)draggingInfo proposedRow:(CPInteger)aRowIndex proposedDropOperation:(CPTableViewDropOperation)anOperation {
// 	if (anOperation == CPTableViewDropAbove) return CPDragOperationNone;
// 
//     var /* CPData */ data = [[draggingInfo draggingPasteboard] dataForType:@"CMColumnDragItemType"];
// 	var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];
// 
// 	if (column) {
// 		return CPDragOperationCopy;
// 	}
// 	
// 	return CPDragOperationNone;
// }


/*
- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	CGContextSetFillColor(context, [CPColor yellowColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x + 5, bounds.origin.y + 5, bounds.size.width - 10., bounds.size.height - 10.)); 
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType {
	return [CPKeyedArchiver archivedDataWithRootObject:[latestContent objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices {
	return ["CMColumnDragItemType"];
}

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(void)context {
	if (object == collectionView) {
		if ([keyPath isEqualToString:@"selectionIndexes"]) {
			var collectionViewItems = [collectionView items];
			var selectedIndex = [[collectionView selectionIndexes] firstIndex];
		}
	}
}
*/

- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pasteboard {
    var encodedData = [CPKeyedArchiver archivedDataWithRootObject:[latestContent objectAtIndex:[rowIndexes firstIndex]]];
    [pasteboard declareTypes:[CPArray arrayWithObject:"CMColumnDragItemType"] owner:self];
    [pasteboard setData:encodedData forType:"CMColumnDragItemType"];

    return YES;
}

@end
