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
/*
	CGPoint originalClickInWindow;
	CGRect originalFrame;

*/
	CPScrollView scrollView;
	CPCollectionView collectionView;
	
	CGSize minItemSize;
	
	CMColumnGroup selectedGroup;
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
		
		selectedGroup = nil;
		[collectionView setContent:[[CMColumnManager sharedManager] columns]];
	} 
	return self;
}

- (void)setFrame:(CGRect)aFrame {
	[super setFrame:aFrame];
	[self configureCollectionViewSize];
}

- (void)configureCollectionViewSize {
	// Every time our view size changes, we need to call this again so we can configure how the collection view is displayed.
	var bounds = [self bounds];
	
	// Calculate the max number of items we can fit on screen using minItemSize.
	var numRows = FLOOR(bounds.size.height / minItemSize);
	[collectionView setMaxNumberOfRows:numRows];
}

- (void)setSelectedGroup:(CMColumnGroup)aGroup {
	selectedGroup = aGroup;
	[collectionView setContent:[selectedGroup members]];
}

/*
- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	CGContextSetFillColor(context, [CPColor yellowColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x + 5, bounds.origin.y + 5, bounds.size.width - 10., bounds.size.height - 10.)); 
}
*/

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType {
	var items = [selectedGroup members];
	return [CPKeyedArchiver archivedDataWithRootObject:[items objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices {
	return ["CMSidebarItemType"];
}

- (void)observeValueForKeyPath:(CPString)keyPath ofObject:(id)object change:(CPDictionary)change context:(void)context {
	if (object == collectionView) {
		if ([keyPath isEqualToString:@"selectionIndexes"]) {
			var collectionViewItems = [collectionView items];
			var selectedIndex = [[collectionView selectionIndexes] firstIndex];
		}
	}
}

@end
