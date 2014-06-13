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
/* 	CPCollectionView collectionView @accessors; */
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
		
/*
		collectionView = [[CPCollectionView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[collectionView setMinItemSize:CGSizeMake([self bounds].size.width, 34)];
		[collectionView setMaxItemSize:CGSizeMake([self bounds].size.width, 34)];
		[collectionView setMaxNumberOfColumns:1];
		[collectionView setAllowsEmptySelection:NO];
		[collectionView setAllowsMultipleSelection:NO];
		[collectionView setVerticalMargin:1.];
		[collectionView setBackgroundColor:[CPColor colorWithHexString:@"dce0e2"]];  // between this and the 1px vertical margin, we get line separators.
		[collectionView setDelegate:self];
		[collectionView addObserver:self forKeyPath:@"selectionIndexes" options:(CPKeyValueObservingOptionNew) context:NULL];

		var itemPrototype = [[CPCollectionViewItem alloc] init];
		[itemPrototype setView:[[CMSidebarItemView alloc] initWithFrame:CGRectMakeZero()]];
		[collectionView setItemPrototype:itemPrototype];
*/

		tableView = [[CPTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[tableView setRowHeight:34];
		[tableView setGridStyleMask:CPTableViewSolidHorizontalGridLineMask];
		//[tableView setBackgroundColor:[CPColor colorWithHexString:@"dce0e2"]];  // between this and the 1px vertical margin, we get line separators.
		[tableView setHeaderView:nil];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
/* 		[tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleNone]; */
/* 		[tableView addObserver:self forKeyPath:@"selectedRowIndexes" options:(CPKeyValueObservingOptionNew) context:NULL]; */
/* 		[tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList]; */
		[tableView setSelectionHighlightColor:nil];
		[tableView setSelectionGradientColors:@{ CPSourceListTopLineColor: [CPColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1],
			                                     CPSourceListBottomLineColor: [CPColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1],
			                                     CPSourceListGradient : CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [ [CPColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1], [CPColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1] ], 0) }];
		[tableView registerForDraggedTypes:[ "CMColumnDragItemType" ]];		

		var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Column 1"];
		[tableColumn setWidth:[self bounds].size.width];
/* 		[tableColumn setShowsHeader:NO]; */
		[tableView addTableColumn:tableColumn];

		[scrollView setDocumentView:tableView];
		[self addSubview:scrollView];

		itemTemplate = [[CMSidebarItemView alloc] initWithFrame:CGRectMake(0, 0, 300, 34)];

/*
		[collectionView setContent:[[CMColumnManager sharedManager] columnGroups]];
		[collectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];

		[collectionView registerForDraggedTypes:[ "CMColumnDragItemType" ]];		
*/

		content = [CPArray array];
		[self updateCollectionView];
	}
	return self;
}

/*
- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	CGContextSetFillColor(context, [CPColor blueColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x + 5, bounds.origin.y + 5, bounds.size.width - 10., bounds.size.height - 10.)); 
}
*/

- (void)updateCollectionView {
/* 	[collectionView setContent:[[CMColumnManager sharedManager] columnGroups]]; */
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
	
	if (selectedIndex < [content count]) {
		[mainView setSelectedGroup:[content objectAtIndex:selectedIndex]];
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
		[self updateCollectionView];
	}
}

- (CPDragOperation)tableView:(CPTableView)aTableView validateDrop:(id)draggingInfo proposedRow:(CPInteger)aRowIndex proposedDropOperation:(CPTableViewDropOperation)anOperation {
	if (anOperation == CPTableViewDropAbove) return CPDragOperationNone;

    var /* CPData */ data = [[draggingInfo draggingPasteboard] dataForType:@"CMColumnDragItemType"];
	var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];

	if (column) {
//		if (aRowIndex > 1) {
			return CPDragOperationCopy;
//		}
	}
	
	return CPDragOperationNone;
}

//- (CPDragOperation)collectionView:(CPCollectionView)cv validateDrop:(id)draggingInfo proposedIndex:(Function)proposedDropIndex dropOperation:(CPCollectionViewDropOperation)proposedDropOperation {
//    var /* CPData */ data = [[draggingInfo draggingPasteboard] dataForType:@"CMColumnDragItemType"];
//	var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];
//	var s = [CPString stringWithFormat:@"%d", proposedDropIndex()];
//	console.log(s);
//	if (column) {
//		if (proposedDropIndex() > 1) {
//			console.log(@"YES");
//			return CPDragOperationCopy;
//		}
//	}
//	
//	console.log(@"no");
//	return CPDragOperationNone;
//}
//
//- (BOOL)collectionView:(CPCollectionView)collectionView acceptDrop:(id)draggingInfo index:(CPInteger)index dropOperation:(CPCollectionViewDropOperation)dropOperation {
//	console.log(@"Accept");
//	return YES;
//}
//
//- (BOOL)collectionView:(CPCollectionView)collectionView canDragItemsAtIndexes:(CPIndexSet)indexes withEvent:(CPEvent)event {
//	return NO;
//}
//
//- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType {
//	return nil;
//}
//
//- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices {
//	return nil;
//}


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

/* Drag methods */
//- (void)performDragOperation:(CPDraggingInfo)aSender {
//    var /* CPData */ data = [[aSender draggingPasteboard] dataForType:[ "CMColumnDragItemType" ]];
//
//	var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];
//	
//}
//
//- (void)draggingEntered:(CPDraggingInfo)aSender {
//}
//
//- (void)draggingExited:(CPDraggingInfo)aSender {
//}
//
@end


@import <AppKit/CPCollectionView.j>
@implementation CPCollectionView (Override)
{
}

- (void)_createDropIndicatorIfNeeded {
	// We always drop onto a collection view item, so we don't want one of these indicators.  Just create it and don't add it as a subview.
    if (!_dropView)
        _dropView = [[_CPCollectionViewDropIndicator alloc] initWithFrame:CGRectMake(-8, -8, 0, 0)];

    [_dropView setFrameSize:CGSizeMake(10, _itemSize.height + _verticalMargin)];
    //[self addSubview:_dropView];
}

@end

