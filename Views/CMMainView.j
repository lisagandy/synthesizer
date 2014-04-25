/*
 * CMMainView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "CMSidebarItemView.j"
@import "../Model/CMColumnManager.j"

@implementation CMMainView : CPView
{
/*
	CGPoint originalClickInWindow;
	CGRect originalFrame;

*/
	CPScrollView scrollView;
	CPCollectionView collectionView;
	
	CGSize minItemSize;
	
	CMColumn selectedColumn;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		minItemSize = CGSizeMake(150, 50);
	
		scrollView = [[CPScrollView alloc] initWithFrame:[self bounds]];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setAutohidesScrollers:NO];
		[scrollView setHasHorizontalScroller:YES];
		[scrollView setHasVerticalScroller:NO];
		
		collectionView = [[CPCollectionView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[collectionView setMinItemSize:CGSizeMake(150, 44)];
 		[collectionView setMaxItemSize:CGSizeMake(150, 44)];
		[collectionView setMaxNumberOfColumns:5];
		[collectionView setMaxNumberOfRows:10];
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
		
		selectedColumn = nil;
		[collectionView setContent:[[CMColumnManager sharedManager] equivalentsForColumn:selectedColumn]];
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
	var numRows = [[CPNumber numberWithInteger:bounds.size.height / minItemSize] integerValue];
}

- (void)setSelectedColumn:(CMColumn)aColumn {
	selectedColumn = aColumn;
	[collectionView setContent:[[CMColumnManager sharedManager] equivalentsForColumn:selectedColumn]];
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
	var items = [[CMColumnManager sharedManager] equivalentsForColumn:selectedColumn];
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

/*
// mouse movement handler
- (void)mouseDown:(CPEvent)anEvent {
        originalClickInWindow = [anEvent locationInWindow];
        originalFrame = [self frame];

        [self setBackgroundColor:[CPColor orangeColor]];
}
 
// on mouse move, we construct a visual hovering effect.     
- (void)mouseDragged:(CPEvent)anEvent {
        var currentLocationInWindow = [anEvent locationInWindow];
        var offset = CGPointMakeZero();
        offset.x = originalClickInWindow.x - currentLocationInWindow.x;
        offset.y = originalClickInWindow.y - currentLocationInWindow.y;

        [self setFrame:CPRectMake(originalFrame.origin.x - offset.x, originalFrame.origin.y - offset.y, originalFrame.size.width, originalFrame.size.height)];
}

- (void)mouseUp:(CPEvent)anEvent {
        [self setBackgroundColor:[CPColor yellowColor]];
}
*/

@end
