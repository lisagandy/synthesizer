/*
 * CMColumnEditorView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 *
 * This view is shown when a column row in the main table is double-clicked.  
 * It provides a method for editing the values of that column so they match 
 * values in equivalent columns from other spreadsheets.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "../Model/CMColumn.j"

@implementation CMColumnEditorView : CPView
{
	CPMainView mainView @accessors;
	
	CPArray allColumns;
	CMColumn editingColumn @accessors;
	
	CPPopUpButton columnNamePopup;
	CPScrollView scrollView;
	CPTableView tableView;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		var bounds = [self bounds];
		var spacing = 10;

		// Column Name Popup
		columnNamePopup = [[CPPopUpButton alloc] initWithFrame:CGRectMake(bounds.origin.x + 20, bounds.origin.y + spacing, bounds.size.width - 40, 25)];
		[columnNamePopup setAutoresizingMask:CPViewMaxYMargin | CPViewWidthSizable];
		var /* CMColumnManager */ columnManager = [CMColumnManager sharedManager];
		allColumns = [columnManager columnsInGroup:[columnManager allGroup]];
		for (var i = 0; i < [allColumns count]; i++) {
			var /* CMColumn */ column = [allColumns objectAtIndex:i];
			[columnNamePopup addItemWithTitle:[column combinedName]];
		}
		[columnNamePopup setTarget:self];
		[columnNamePopup setAction:@selector(popupChanged:)];
		[self addSubview:columnNamePopup];
	}
	return self;
}

- (void)setEditingColumn:(CMColumn)aColumn {
	editingColumn = aColumn;
	
	[columnNamePopup selectItemWithTitle:[editingColumn combinedName]];
	
	[self refreshDisplay];
}

- (void)refreshDisplay {
	var bounds = [self bounds];
	var spacing = 10;

	if (!scrollView) {
		var scrollViewOriginY = [columnNamePopup frame].origin.y + [columnNamePopup frame].size.height + spacing;
		
		scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(bounds.origin.x, scrollViewOriginY, bounds.size.width, bounds.size.height - scrollViewOriginY)];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setHasHorizontalScroller:NO];
		[scrollView setHasVerticalScroller:YES];
				
		tableView = [[CPTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[tableView setUsesAlternatingRowBackgroundColors:YES];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView setTarget:self];

		var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Original Value"];
		[tableColumn setWidth:bounds.size.width * 0.5 - 3];
		[[tableColumn headerView] setStringValue:@"Original Value"];
		[tableView addTableColumn:tableColumn];
		
		tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Modified Value"];
		[tableColumn setWidth:bounds.size.width * 0.5 - 3];
		[tableColumn setEditable:YES];
		[[tableColumn headerView] setStringValue:@"Modified Value (Editable)"];
		[tableView addTableColumn:tableColumn];

		[scrollView setDocumentView:tableView];
		[self addSubview:scrollView];
	}
	
	[tableView reloadData];
}

- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds];
	
	[[CPColor colorWithWhite:0.757 alpha:1.000] set];
	var context = [[CPGraphicsContext currentContext] graphicsPort];
	CGContextFillRect(context, CGRectMake(bounds.origin.x, [scrollView frame].origin.y - 1, bounds.size.width, 1));
}

- (IBAction)popupChanged:(id)sender {
	var selectedIndex = [columnNamePopup indexOfSelectedItem];
	if (selectedIndex < [allColumns count]) {
		[self setEditingColumn:[allColumns objectAtIndex:selectedIndex]];
	}
}

- (int)numberOfRowsInTableView:(id)tableView {
/*     console.log("Num rows: " + MIN([[editingColumn originalValues] count], [[editingColumn modifiedValues] count])); */
    return MIN([[editingColumn originalValues] count], [[editingColumn modifiedValues] count]);
}

- (id)tableView:(id)tableView objectValueForTableColumn:(CPTableColumn)aColumn row:(CPInteger)aRow {
    if ([aColumn identifier] == "Original Value")
        return [[editingColumn originalValues] objectAtIndex:aRow];
    else if ([aColumn identifier] == "Modified Value")
        return [[editingColumn modifiedValues] objectAtIndex:aRow];
    else 
    	return "error";
}


- (void)tableView:(CPTableView)aTableView setObjectValue:(id)anObject forTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRow {
/* 	console.log("Column:  " + aTableColumn + "\nRow:  " + aRow + "\nObject:  " + anObject); */
	if ([aTableColumn identifier] == "Modified Value") {
		if (aRow < [[editingColumn modifiedValues] count]) {
			var /* CPMutableArray */ newModifiedValues = [CPMutableArray arrayWithArray:[editingColumn modifiedValues]];
			[newModifiedValues removeObjectAtIndex:aRow];
			[newModifiedValues insertObject:anObject atIndex:aRow];
			[editingColumn setModifiedValues:newModifiedValues];
		}
	}
}

@end
