/*
 * CMHeaderView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 29, 2014.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMHeaderView : CPView
{
	CPMainView mainView @accessors;
	
	CPGradient backgroundGradient;
	CPTextField title;
	CPSearchField searchField;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		backgroundGradient = CMHeadingGradient;
		
		title = [[CPTextField alloc] initWithFrame:CGRectInset(aFrame, 10, 0)];
		[title setFont:[CPFont boldSystemFontOfSize:20.0]];
		[title setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
		[title setAlignment:CPCenterTextAlignment];
		[title setVerticalAlignment:CPCenterVerticalTextAlignment];
		[title setTextColor:[CPColor whiteColor]];
		[title setStringValue:@"Column Merger"];
		[self addSubview:title];

		
		searchField = [[ToolbarSearchField alloc] initWithFrame:CGRectMake(aFrame.origin.x + aFrame.size.width - 10 - 140, aFrame.origin.y + 5, 140, 30)];
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
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds];
	[backgroundGradient drawInRect:bounds angle:90];
	
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 
	CGContextSetFillColor(context, [CPColor darkGrayColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height - 1, bounds.size.width, 1)); 
}

- (void)filterColumns:(CPSearchField)sender {
	[mainView setTextFilter:[sender stringValue]];
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

