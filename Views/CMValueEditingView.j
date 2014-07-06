/*
 * CMHeaderView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 29, 2014.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
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
	CPButton doneButton;
	
	var headerHeight;
	var radius;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		headerHeight = 44;
		radius = 8;

/*
		title = [[CPTextField alloc] initWithFrame:CGRectInset(aFrame, 10, 0)];
		[title setFont:[CPFont boldSystemFontOfSize:20.0]];
		[title setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
		[title setAlignment:CPCenterTextAlignment];
		[title setVerticalAlignment:CPCenterVerticalTextAlignment];
		[title setTextColor:[CPColor whiteColor]];
		[title setStringValue:@"Column Merger"];
		[self addSubview:title];
*/
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
		[columnNameLabel setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[columnNameLabel setVerticalAlignment:CPBottomVerticalTextAlignment];
		[self addSubview:columnNameLabel];
	}
	
	if (!columnSpreadsheetLabel) {
		columnSpreadsheetLabel = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x + 10., bounds.origin.y + (headerHeight * .6), bounds.size.width - 20., headerHeight * .4)];
		[columnSpreadsheetLabel setFont:[CPFont systemFontOfSize:10.0]];
		[columnSpreadsheetLabel setTextColor:[CPColor whiteColor]];
		[columnSpreadsheetLabel setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[columnSpreadsheetLabel setVerticalAlignment:CPTopVerticalTextAlignment];
		[self addSubview:columnSpreadsheetLabel];
	}
	
	if (!doneButton) {
		doneButton = [[CPButton alloc] initWithFrame:CGRectMake(bounds.origin.x + bounds.size.width - 60, bounds.origin.y + 5, 60, headerHeight - 10)];
		[doneButton setBezelStyle:CPHUDBezelStyle];
		[doneButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
		[doneButton setTitle:"Done"];
		[doneButton setTarget:self];
		[doneButton setAction:@selector(done:)];
		[self addSubview:doneButton];
	}
		
	[columnNameLabel setStringValue:[editingColumn name]];
	[columnSpreadsheetLabel setStringValue:[editingColumn spreadsheet]];
}

- (void)drawRect:(CGRect)rect {
	var bounds = CPRectInset([self bounds], 2, 2);

	var bp = [CPBezierPath bezierPathWithRoundedRect:bounds xRadius:radius yRadius:radius];
	[bp setLineWidth:2];
	[[CPColor whiteColor] set];	
	[bp fill];	
	
	var context = [[CPGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(context);
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + radius);
	CGContextAddArc(context, bounds.origin.x + radius, bounds.origin.y + radius, radius, -PI, -PI_2, YES);
	CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y);
	CGContextAddArc(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y + radius, radius, -PI_2, 0, YES);
	CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height - radius);
	CGContextAddArc(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y + bounds.size.height - radius, radius, 0, PI_2, YES);
	CGContextAddLineToPoint(context, bounds.origin.x + radius, bounds.origin.y + bounds.size.height);
	CGContextAddArc(context, bounds.origin.x + radius, bounds.origin.y + bounds.size.height - radius, radius, PI_2, PI, YES);
	CGContextClip(context);	
	
	[CMHeadingGradient drawInRect:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 44.) angle:90];

	CGContextRestoreGState(context);
	
	[[CPColor darkGrayColor] set];
	[bp stroke];
	
/*
	[backgroundGradient drawInRect:bounds angle:90];
	
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 
	CGContextSetFillColor(context, [CPColor darkGrayColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height - 1, bounds.size.width, 1)); 
*/
}

- (IBAction)done:(id)sender {
	[mainView closeValueEditor];
}

@end
