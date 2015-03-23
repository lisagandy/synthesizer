/*
 * CMHeaderView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 *
 * This class represents the view that acts as the page header: a blue 
 * bar with button actions and a search box.  It sets up the interface
 * in the header as well as serves as the target object when events 
 * originating from the header take place. 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMHeaderView : CPView
{
	CPMainView mainView @accessors;
	
	CPButton addGroupButton;
	CPButton editValuesButton;
	CPTextField title;
	CPSearchField searchField;
	CPButton saveButton;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {		
		title = [[CPTextField alloc] initWithFrame:CGRectInset(aFrame, 10, 0)];
		[title setFont:[CPFont systemFontOfSize:20.0]];
		[title setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin];
		[title setAlignment:CPCenterTextAlignment];
		[title setVerticalAlignment:CPCenterVerticalTextAlignment];
		[title setTextColor:[CPColor whiteColor]];
		[title setStringValue:@"Column Merger"];
		[self addSubview:title];
		
		searchField = [[ToolbarSearchField alloc] initWithFrame:CGRectMake(aFrame.origin.x + aFrame.size.width - 10 - 140 - 60 - 10, aFrame.origin.y + 5, 140, 30)];
		[searchField setAutoresizingMask:CPViewMinXMargin];
		[searchField setTarget:self];
		[searchField setAction:@selector(filterColumns:)];
		[searchField setSendsSearchStringImmediately:YES];
		[searchField setPlaceholderString:@"Filter Columns"];

		var bezelColor = CPColorWithImages(
			[
				["searchfield-left-bezel.png", 23, 24],
				["searchfield-center-bezel.png", 1, 24],
				["searchfield-right-bezel.png", 14, 24]
			], CPColorPatternIsHorizontal);
		
		var bezelFocusedColor = CPColorWithImages(
			[
				["searchfield-left-bezel-selected.png", 27, 30],
				["searchfield-center-bezel-selected.png", 1, 30],
				["searchfield-right-bezel-selected.png", 17, 30]
			], CPColorPatternIsHorizontal);
		
		[searchField setValue:bezelColor forThemeAttribute:@"bezel-color" inState:CPThemeStateBezeled | CPTextFieldStateRounded];
		[searchField setValue:bezelFocusedColor forThemeAttribute:@"bezel-color" inState:CPThemeStateBezeled | CPTextFieldStateRounded | CPThemeStateEditing];
		
		[searchField setValue:[CPFont systemFontOfSize:12.0] forThemeAttribute:@"font"];
		[searchField setValue:CGInsetMake(10.0, 14.0, 6.0, 14.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled | CPTextFieldStateRounded];
		
		[searchField setValue:CGInsetMake(3.0, 3.0, 3.0, 3.0) forThemeAttribute:@"bezel-inset" inState:CPThemeStateBezeled | CPTextFieldStateRounded];
		[searchField setValue:CGInsetMake(0.0, 0.0, 0.0, 0.0) forThemeAttribute:@"bezel-inset" inState:CPThemeStateBezeled | CPTextFieldStateRounded | CPThemeStateEditing];
		[searchField setValue:CGInsetMake(9.0, 14.0, 6.0, 14.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled | CPTextFieldStateRounded | CPThemeStateEditing];
		
		[self addSubview:searchField];

		addGroupButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, aFrame.size.height, aFrame.size.height)];
		[addGroupButton setBordered:NO];
		[addGroupButton setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[addGroupButton setImage:[[CPImage alloc] initWithContentsOfFile:("Resources/add-group.png") size:CPSizeMake(15, 15)]];
		[addGroupButton setTarget:self];
		[addGroupButton setAction:@selector(addGroup:)];
		[addGroupButton setImagePosition:CPImageOnly];
		[self addSubview:addGroupButton];

		editValuesButton = [[CPButton alloc] initWithFrame:CGRectMake(aFrame.size.height, 0, aFrame.size.height, aFrame.size.height)];
		[editValuesButton setBordered:NO];
		[editValuesButton setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
		[editValuesButton setImage:[[CPImage alloc] initWithContentsOfFile:("Resources/edit-values.png") size:CPSizeMake(19, 19)]];
		[editValuesButton setTarget:self];
		[editValuesButton setAction:@selector(editValues:)];
		[editValuesButton setImagePosition:CPImageOnly];
		[self addSubview:editValuesButton];

		saveButton = [[CPButton alloc] initWithFrame:CGRectMake(aFrame.origin.x + aFrame.size.width - 10 - 60, 4, 60, 34)];
		[saveButton setBordered:NO];
		[saveButton setFont:[CPFont systemFontOfSize:18]];
		[saveButton setTextColor:[CPColor whiteColor]];
		[saveButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
		[saveButton setTitle:"Merge"];
		[saveButton setTarget:self];
		[saveButton setAction:@selector(save:)];
		[self addSubview:saveButton];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds];
	[CMHeadingGradient drawInRect:bounds angle:90];
	
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 
	CGContextSetFillColor(context, [CPColor darkGrayColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height - 1, bounds.size.width, 1)); 
}

- (void)filterColumns:(CPSearchField)sender {
	[mainView setTextFilter:[sender stringValue]];
}

- (IBAction)save:(CPButton)sender {
	var /* CMCSV */ csv = [[CMColumnManager sharedManager] exportCSV];
	var /* CPString */ csvText = [csv exportCSV];
	
	// convert " in CSV to &#34;
	csvText = csvText.replace(/"/g, '&#34;');


	var /* CPString */ html = "<form id=\"downloadForm\" method=\"POST\" action=\"/cgi-bin/columnmerger-download.cgi\"><input type=\"hidden\" name=\"csv_text\" value=\"" + csvText + "\"></form><script>document.getElementById('downloadForm').submit(); </script>'";

/*
	var myWindow = window.open("", "MsgWindow", "width=300, height=200");
	myWindow.document.write(html);
*/

	var frame = document.createElement("IFRAME");
	frame.style.display = "none";
	frame.srcdoc = html;
/*
	var frameDocument = frame.contentDocument;
	frameDocument.write(html);
*/
	document.body.appendChild(frame);
}

- (IBAction)addGroup:(CPButton)sender {
	var /* CPString */ defaultGroupName = @"Untitled Group";

	var /* CPArray */ columnGroups = [[CMColumnManager sharedManager] columnGroups];
	var /* CPMutableArray */ mutColumnGroups = [CPMutableArray array];
	if (columnGroups) [mutColumnGroups addObjectsFromArray:columnGroups];
	
	var addedGroup = [[CMColumnGroup alloc] initWithName:defaultGroupName];
	
	// Check if we need to add a digit to the end of the group name.
	var maxNumber = 0;
	for (var i = 0; i < [mutColumnGroups count]; i++) {
		var /* CMColumnGroup */ group = mutColumnGroups[i];
		var /* CPString */ groupName = [group name];
		
		if ([groupName hasPrefix:defaultGroupName]) {
			var groupNumber = 1;
			if ([groupName length] > [defaultGroupName length]) {
				// A number is appended to this name.  Check to see what the number is so we can compare it to our max.
				var /* CPString */ numberString = [groupName substringFromIndex:[defaultGroupName length] + 1];
				var /* CPInteger */ numberStringIntValue = [numberString intValue];
				if (numberStringIntValue > 1) groupNumber = numberStringIntValue;
			}
			
			if (groupNumber > maxNumber) {
				maxNumber = groupNumber;
			}
		}
	}
	
	if (maxNumber > 0) {
		[addedGroup setName:[defaultGroupName stringByAppendingFormat:@" %d", maxNumber + 1]];
	}
	
	[mutColumnGroups addObject:addedGroup];
	[[CMColumnManager sharedManager] setColumnGroups:mutColumnGroups];
	
	// Scroll the table view to the new group and highlight it.
	var /* CMSidebarView */ sidebarView = [[CMColumnManager sharedManager] sidebarView];
	var /* CPInteger */ addedGroupIndex = [[[CMColumnManager sharedManager] columnGroups] indexOfObject:addedGroup];
	[[sidebarView tableView] scrollRowToVisible:addedGroupIndex];
	[[sidebarView tableView] selectRowIndexes:[CPIndexSet indexSetWithIndex:addedGroupIndex] byExtendingSelection:NO];
}

- (IBAction)editValues:(CPButton)sender {
	[mainView openValueEditor:nil];
}

@end


/*
Copyright 2010 280 North, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
 
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
@implementation ToolbarSearchField : CPSearchField
{
}

- (void)resetSearchButton {
    [super resetSearchButton];
    [[self searchButton] setImage:nil];
}

@end

