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
	CPCollectionView collectionView @accessors;
	
	CPMainView mainView @accessors;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		scrollView = [[CPScrollView alloc] initWithFrame:[self bounds]];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setAutohidesScrollers:NO];
		[scrollView setHasHorizontalScroller:NO];
		
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

		[scrollView setDocumentView:collectionView];
		[self addSubview:scrollView];
		
		[collectionView setContent:[[CMColumnManager sharedManager] columnGroups]];
		[collectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];

		[collectionView registerForDraggedTypes:[ "CMColumnDragItemType" ]];		
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
	[collectionView setContent:[[CMColumnManager sharedManager] columnGroups]];
	
	var items = [[CMColumnManager sharedManager] columnGroups];
	var selectedIndex = [[collectionView selectionIndexes] firstIndex];
	
	if (selectedIndex < [items count]) {
		[mainView setSelectedGroup:[items objectAtIndex:selectedIndex]];
	}
}

- (CPDragOperation)collectionView:(CPCollectionView)cv validateDrop:(id)draggingInfo proposedIndex:(Function)proposedDropIndex dropOperation:(CPCollectionViewDropOperation)proposedDropOperation {
    var /* CPData */ data = [[draggingInfo draggingPasteboard] dataForType:@"CMColumnDragItemType"];
	var /* CMColumn */ column = [CPKeyedUnarchiver unarchiveObjectWithData:data];
	var s = [CPString stringWithFormat:@"%d", proposedDropIndex()];
	console.log(s);
	if (column) {
		if (proposedDropIndex() > 1) {
			console.log(@"YES");
			return CPDragOperationCopy;
		}
	}
	
	console.log(@"no");
	return CPDragOperationNone;
}

- (BOOL)collectionView:(CPCollectionView)collectionView acceptDrop:(id)draggingInfo index:(CPInteger)index dropOperation:(CPCollectionViewDropOperation)dropOperation {
	console.log(@"Accept");
	return YES;
}

- (BOOL)collectionView:(CPCollectionView)collectionView canDragItemsAtIndexes:(CPIndexSet)indexes withEvent:(CPEvent)event {
	return NO;
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType {
	return nil;
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices {
	return nil;
}


- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(void)context {
	if (object == collectionView) {
		if ([keyPath isEqualToString:@"selectionIndexes"]) {
			var items = [[CMColumnManager sharedManager] columnGroups];
			var selectedIndex = [[collectionView selectionIndexes] firstIndex];
			
			if (selectedIndex < [items count]) {
				[mainView setSelectedGroup:[items objectAtIndex:selectedIndex]];
			}
		}
	}
}

- (CPArray)columnGroups {
	
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

