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

@implementation CMSidebarView : CPView
{
	CGPoint originalClickInWindow;
	CGRect originalFrame;
	
	CPScrollView scrollView;
	CPCollectionView collectionView;
	
	CPArray items;
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
		[collectionView setVerticalMargin:1.];
		[collectionView setBackgroundColor:[CPColor colorWithHexString:@"dce0e2"]];  // between this and the 1px vertical margin, we get line separators.
		[collectionView setDelegate:self];
		
		var itemPrototype = [[CPCollectionViewItem alloc] init];
		[itemPrototype setView:[[CMSidebarItemView alloc] initWithFrame:CGRectMakeZero()]];
		[collectionView setItemPrototype:itemPrototype];

		[scrollView setDocumentView:collectionView];
		[self addSubview:scrollView];
		
		items = [ @"foo", @"goo", @"roo", @"moo", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l" ];
		[collectionView setContent:items];
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

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType {
	return [CPKeyedArchiver archivedDataWithRootObject:[items objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices {
	return ["CMSidebarItemType"];
}


/*
- (id)outlineView:(CPOutlineView)outlineV child:(int)index ofItem:(id)item {
	CPLog("outlineView:%@ child:%@ ofItem:%@", outlineView, index, item);
	
	if (item == nil) {
		var keys = [items allKeys];
		return [keys objectAtIndex:index];
	}
	else {
		var values = [items objectForKey:item];
		return [values objectAtIndex:index];
	}
}
 
- (BOOL)outlineView:(CPOutlineView)outlineV isItemExpandable:(id)item {
	var values = [items objectForKey:item];
	return ([values count] > 0);
}
 
- (int)outlineView:(CPOutlineView)outlineV numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return [items count];
	}
	else {
		var values = [items objectForKey:item];
		return [values count];
	}
}
 
- (id)outlineView:(CPOutlineView)outlineV objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item {
    return item;   
}
*/

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
