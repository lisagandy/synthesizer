/*
 * CMValueEditingView.j
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

@implementation CMValueEditingView : CPView
{
	CPMainView mainView @accessors;
	CMColumn editingColumn @accessors;
	
	CPTextField columnNameLabel;
	CPTextField columnSpreadsheetLabel;
	CPPopUpButton columnNamePopup;
	CPScrollView scrollView;
	CPTableView tableView;
	
	var headerHeight;
	var radius;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		headerHeight = 44;
		radius = 8;
	}
	return self;
}

- (void)setEditingColumn:(CMColumn)aColumn {
	editingColumn = aColumn;
	[self refreshDisplay];
}

- (void)refreshDisplay {
	var bounds = [self bounds];

	if (!columnNameLabel) {
		columnNameLabel = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x + 10., bounds.origin.y, bounds.size.width - 20., headerHeight * 0.6)];
		[columnNameLabel setFont:[CPFont systemFontOfSize:14.0]];
		[columnNameLabel setTextColor:[CPColor whiteColor]];
		[columnNameLabel setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[columnNameLabel setVerticalAlignment:CPBottomVerticalTextAlignment];
		[self addSubview:columnNameLabel];
	}
	
	if (!columnSpreadsheetLabel) {
		columnSpreadsheetLabel = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x + 10., bounds.origin.y + (headerHeight * .6), bounds.size.width - 20., headerHeight * .4)];
		[columnSpreadsheetLabel setFont:[CPFont systemFontOfSize:10.0]];
		[columnSpreadsheetLabel setTextColor:[CPColor whiteColor]];
		[columnSpreadsheetLabel setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[columnSpreadsheetLabel setVerticalAlignment:CPTopVerticalTextAlignment];
		[self addSubview:columnSpreadsheetLabel];
	}
	
	if (!doneButton) {
		doneButton = [[CPButton alloc] initWithFrame:CGRectMake(bounds.origin.x + bounds.size.width - 70, bounds.origin.y + 7, 60, headerHeight - 10)];
		[doneButton setBordered:NO];
		[doneButton setFont:[CPFont systemFontOfSize:18]];
		[doneButton setTextColor:[CPColor whiteColor]];
		[doneButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
		[doneButton setTitle:"Done"];
		[doneButton setTarget:self];
		[doneButton setAction:@selector(done:)];
		[self addSubview:doneButton];
	}
	
	if (!scrollView) {
		scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(bounds.origin.x + 1, bounds.origin.y + headerHeight, bounds.size.width - 2, bounds.size.height - headerHeight - 1)];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setHasHorizontalScroller:NO];
		[scrollView setHasVerticalScroller:YES];
				
		tableView = [[CPTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[tableView setUsesAlternatingRowBackgroundColors:YES];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView setTarget:self];

		var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Original Value"];
		[tableColumn setWidth:bounds.size.width * 0.5];
		[[tableColumn headerView] setStringValue:@"Original Value"];
		[tableView addTableColumn:tableColumn];
		
		tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Modified Value"];
		[tableColumn setWidth:bounds.size.width * 0.5];
		[tableColumn setEditable:YES];
		[[tableColumn headerView] setStringValue:@"Modified Value (Editable)"];
		[tableView addTableColumn:tableColumn];

		[scrollView setDocumentView:tableView];
		[self addSubview:scrollView];
	}
	
	[tableView reloadData];
		
	[columnNameLabel setStringValue:[editingColumn name]];
	[columnSpreadsheetLabel setStringValue:[editingColumn spreadsheet]];
}

- (void)drawRect:(CGRect)rect {
	var bounds = CPRectInset([self bounds], 2, 2);
}

- (IBAction)done:(id)sender {
	[mainView closeValueEditor];
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
