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

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType {
	var items = [[CMColumnManager sharedManager] columnGroups];
	return [CPKeyedArchiver archivedDataWithRootObject:[items objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices {
	return ["CMSidebarItemType"];
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

@end
