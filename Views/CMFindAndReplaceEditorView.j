/*
 * CMFindAndReplaceEditorView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014-2015, Gaucho Software, LLC.  All rights reserved.
 *
 * This view is shown when a column row in the main table is double-clicked.  
 * It provides a method for editing the values of that column so they match 
 * values in equivalent columns from other spreadsheets.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "CMEditorView.j"
@import "CMColumnEditorView.j"

@import "../Base/CMCommon.j"
@import "../Model/CMColumn.j"

@implementation CMFindAndReplaceEditorView : CPView
{
	CMEditorView parentView @accessors;
	
	CPTextField findLabel;
	CPTextField findValue;
	
	CPTextField replaceLabel;
	CPTextField replaceValue;
	CPButton replaceButton;
	
	CPTextField briefInstructions;
	CPScrollView scrollView;
	CPTableView tableView;
	
	CPArray columnSearchResults;  			// Array of CMColumn objects.
	CPArray columnSearchResultsEnabled;   	// Array of CPNumber objects with BOOL values, CPOnState if enabled, CPOffState if disabled.  Always the same size as columnSearchResults and updated in setColumnSearchResults.
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		var bounds = [self bounds];
		var spacing = 8;
		var labelWidth = 80;
		var buttonWidth = 80;
		var verticalLabelBezelOffset = 7;
		
		// Find label and text field.
		findLabel = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x + spacing, bounds.origin.y + spacing + verticalLabelBezelOffset, labelWidth, 25)];
		[findLabel setStringValue:"Find:"];
		[findLabel setFont:[CPFont systemFontOfSize:14.0]];
		[findLabel setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[findLabel setAlignment:CPRightTextAlignment];
		[self addSubview:findLabel];
		var findLabelFrame = [findLabel frame];

		findValue = [[CPTextField alloc] initWithFrame:CGRectMake(findLabelFrame.origin.x + findLabelFrame.size.width + spacing, bounds.origin.y + spacing, aFrame.size.width - spacing - labelWidth - spacing - spacing - buttonWidth - spacing, 31)];
		[findValue setEditable:YES];
		[findValue setBezeled:YES];
		[findValue setBezelStyle:CPTextFieldSquareBezel];
		[findValue setFont:[CPFont systemFontOfSize:14.0]];
		[findValue setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[findValue setDelegate:self];
		[self addSubview:findValue];
		var findValueFrame = [findValue frame];

		// Replace label and text field.
		replaceValue = [[CPTextField alloc] initWithFrame:CGRectMake(findValueFrame.origin.x, findValueFrame.origin.y + findValueFrame.size.height + spacing, findValueFrame.size.width, findValueFrame.size.height)];
		[replaceValue setEditable:YES];
		[replaceValue setBezeled:YES];
		[replaceValue setBezelStyle:CPTextFieldSquareBezel];
		[replaceValue setFont:[CPFont systemFontOfSize:14.0]];
		[replaceValue setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[self addSubview:replaceValue];
		var replaceValueFrame = [replaceValue frame];

		replaceLabel = [[CPTextField alloc] initWithFrame:CGRectMake(findLabelFrame.origin.x, replaceValueFrame.origin.y + verticalLabelBezelOffset, findLabelFrame.size.width, findLabelFrame.size.height)];
		[replaceLabel setStringValue:"Replace:"];
		[replaceLabel setFont:[CPFont systemFontOfSize:14.0]];
		[replaceLabel setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[replaceLabel setAlignment:CPRightTextAlignment];
		[self addSubview:replaceLabel];
		var replaceLabelFrame = [replaceLabel frame];
		
		replaceButton = [[CPButton alloc] initWithFrame:CGRectMake(bounds.origin.x + bounds.size.width - spacing - buttonWidth, replaceValueFrame.origin.y + 3, buttonWidth, 25)];
		[replaceButton setTitle:"Replace"];
		[replaceButton setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[replaceButton setTarget:self];
		[replaceButton setAction:@selector(replaceAction:)];
		[self addSubview:replaceButton];
		
		// Brief instructions.
		briefInstructions = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x, replaceValueFrame.origin.y + replaceValueFrame.size.height + spacing, bounds.size.width, 15)];
		[briefInstructions setStringValue:"Select spreadsheet columns to replace matching values."];
		[briefInstructions setFont:[CPFont systemFontOfSize:12]];
		[briefInstructions setTextColor:[CPColor darkGrayColor]];
		[briefInstructions setAlignment:CPCenterTextAlignment];
		[self addSubview:briefInstructions];
		var briefInstructionsFrame = [briefInstructions frame];
		
		// Matching columns table
		var scrollViewOriginY = briefInstructionsFrame.origin.y + briefInstructionsFrame.size.height + 1;
		scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(bounds.origin.x - 1, scrollViewOriginY, bounds.size.width + 2, bounds.size.height - scrollViewOriginY + 2)];
		[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[scrollView setHasHorizontalScroller:NO];
		[scrollView setHasVerticalScroller:YES];
		[scrollView setBorderType:CPLineBorder];
				
		tableView = [[CPTableView alloc] initWithFrame:[[scrollView contentView] bounds]];
		[tableView setUsesAlternatingRowBackgroundColors:YES];
		[tableView setHeaderView:nil];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView setTarget:self];
		[tableView setDoubleAction:@selector(rowDoubleClicked:)];

		var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Blank"];
		[tableColumn setWidth:8];
        [tableColumn setEditable:NO];
		[tableView addTableColumn:tableColumn];

		tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Matching Column Enabled"];
		[tableColumn setWidth:20];
        [tableColumn setEditable:YES];
        [tableColumn setDataView:[CPCheckBox checkBoxWithTitle:@""]];
		[tableView addTableColumn:tableColumn];

		tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"Matching Column Name"];
		[tableColumn setWidth:bounds.size.width - 40];
		[[tableColumn headerView] setStringValue:@"Replace values in selected matching columns"];
        [tableColumn setEditable:NO];
		[tableView addTableColumn:tableColumn];
		
		[scrollView setDocumentView:tableView];
		[self addSubview:scrollView];
		
		// Set next and previous key views for the text fields.
		[findValue setNextKeyView:replaceValue];
		[replaceValue setNextKeyView:findValue];
	}
	return self;
}

- (void)viewDidAppear {
	[findValue selectText:self];
}

- (void)setColumnSearchResults:(CPArray)updatedArray {
	columnSearchResults = updatedArray;
	
	// Set columnSearchResultsEnabled to an array of size [updatedArray count] with 1s as values.
	var updatedEnabled = [CPMutableArray array];
	for (var i = 0; i < [updatedArray count]; i++) {
		[updatedEnabled addObject:[CPNumber numberWithInt:CPOnState]];
	}
	
	columnSearchResultsEnabled = updatedEnabled;
}

- (IBAction)replaceAction:(id)sender {
	var numReplacements = 0;
	
	if ([columnSearchResults count] == [columnSearchResultsEnabled count]) {
		for (var i = 0; i < [columnSearchResults count]; i++) {
			if ([[columnSearchResultsEnabled objectAtIndex:i] intValue] == CPOnState) {
				// Do the replacement.
				numReplacements += [[columnSearchResults objectAtIndex:i] replaceValue:[findValue stringValue] withValue:[replaceValue stringValue]];
			}
		}	
	}
	
	// Show a dialog confirming the replacement.
	var alert = [[CPAlert alloc] init];
	[alert addButtonWithTitle:"OK"];
	[alert setMessageText:numReplacements + " values replaced."];
	[alert setInformativeText:""];
	[alert setAlertStyle:CPInformationalAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)drawRect:(CGRect)rect {
}

/* Search results - Filter for matching columns. */
- (void)controlTextDidChange:(CPNotification)notification {
	if ([notification object] == findValue) {
		[self searchColumnValuesForString:[findValue stringValue]];
	}
}

// This method will run the actual search and populate the columnSearchResults with matching CMColumn objects.  Note that this method will only search the original column values, and not modified column values.
- (void)searchColumnValuesForString:(CPString)searchString {
	var /* CMColumnManager */ columnManager = [CMColumnManager sharedManager];
	[self setColumnSearchResults:[columnManager columnsWithValuesMatchingString:searchString]];
	[tableView reloadData];
}

/* Search results - Matching columns table. */
- (int)numberOfRowsInTableView:(id)tableView {
	return [columnSearchResults count];
}

- (id)tableView:(id)tableView objectValueForTableColumn:(CPTableColumn)aColumn row:(CPInteger)aRow {
    if ([[aColumn identifier] isEqualToString:@"Matching Column Name"]) {
        return [[columnSearchResults objectAtIndex:aRow] combinedName];	    
    }
    else if ([[aColumn identifier] isEqualToString:@"Matching Column Enabled"]) {
        return [columnSearchResultsEnabled objectAtIndex:aRow];
    }
    else if ([[aColumn identifier] isEqualToString:@"Blank"]) {
	    return "";
    }
    else 
    	return "error";
}

- (void)tableView:(CPTableView)aTableView setObjectValue:(id)anObject forTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRow {
	if ([[aTableColumn identifier] isEqualToString:"Matching Column Enabled"]) {
		if (aRow < [columnSearchResults count]) {
			console.log("Set object value: " + anObject + " for row: " + aRow + " and column: " + aTableColumn);
			[columnSearchResultsEnabled replaceObjectAtIndex:aRow withObject:anObject];
		}
	}
}

- (void)rowDoubleClicked:(id)sender {
	var /* CMColumn */ columnClicked = nil;
	if ([self.tableView clickedRow] < [columnSearchResults count]) {
		columnClicked = columnSearchResults[[tableView clickedRow]];
	}
	
	if (columnClicked) [self switchToValueEditor:columnClicked];
}

- (void)switchToValueEditor:(CMColumn)editingColumn {
	if (parentView) {
		[parentView setEditingColumn:editingColumn];
		[parentView setSelectedSegment:0];
	}
}

@end
