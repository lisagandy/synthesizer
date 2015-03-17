/*
 * CMEditorView.j
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

@import "CMValueEditingView.j"

@import "../Base/CMCommon.j"
@import "../Model/CMColumn.j"

@implementation CMEditorView : CPView
{
	CPMainView mainView @accessors;
	CPButton doneButton;

	CPSegmentedControl segments;
	var selectedSegment @accessors;	
	CMValueEditingView segment1View;    // Tab 1 - Edit Column Values
	CPView segment2View;				// Tab 2 - Find and Replace
	
	var headerHeight;
	var radius;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		headerHeight = 39;
		radius = 5;
		selectedSegment = 0;
		
		var bounds = CPRectInset([self bounds], 2, 2);

		// Segment Control
		var ratio = 0.7;
		segments = [[CPSegmentedControl alloc] initWithFrame:CGRectMake(bounds.origin.x + (0.5 * (1 - ratio)) * bounds.size.width, bounds.origin.y + 7, bounds.size.width * ratio, 25)];
		[segments setSegmentCount:2];
		[segments setSelectedSegment:0];
		[segments setLabel:"Edit Column Values" forSegment:0];
		[segments setLabel:"Find and Replace" forSegment:1];
		[segments setWidth:bounds.size.width * 0.5 * ratio forSegment:0];
		[segments setWidth:bounds.size.width * 0.5 * ratio forSegment:1];
		[segments setTarget:self];
		[segments setAction:@selector(selectSegment:)];
		[segments setAutoresizingMask:CPViewMaxYMargin | CPViewWidthSizable];
		[self addSubview:segments];

		// Segment 1 View
		segment1View = [[CMValueEditingView alloc] initWithFrame:CGRectMake(bounds.origin.x + 1, bounds.origin.y + headerHeight, bounds.size.width - 2, bounds.size.height - headerHeight - 1)];
		[segment1View setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
		[self addSubview:segment1View];

		// Done Button
		doneButton = [[CPButton alloc] initWithFrame:CGRectMake(bounds.origin.x + bounds.size.width - 30, bounds.origin.y + 7, 20, headerHeight - 10)];
		[doneButton setBordered:NO];
		[doneButton setFont:[CPFont systemFontOfSize:18]];
		[doneButton setTextColor:[CPColor colorWithHue:CMPrimaryColorHue saturation:CMPrimaryColorSaturation brightness:CMPrimaryColorBrightness alpha:1]];
		[doneButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
		[doneButton setTitle:"x"];
		[doneButton setTarget:self];
		[doneButton setAction:@selector(done:)];
		[doneButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
		[self addSubview:doneButton];

		[self setNeedsDisplay:YES];
	}
	return self;
}

- (void)setEditingColumn:(CMColumn)aColumn {
	[segment1View setEditingColumn:aColumn];
}

- (void)setSelectedSegment:(var)segmentNumber {
	selectedSegment = segmentNumber;
	if ([segments selectedSegment] != segmentNumber) {
		[segments setSelectedSegment:segmentNumber];
	}
	[self refreshDisplay];
}

- (void)refreshDisplay {
	var bounds = CPRectInset([self bounds], 2, 2);
}

- (void)drawRect:(CGRect)rect {
	var bounds = CPRectInset([self bounds], 2, 2);
	
	[self refreshDisplay];

	var bp = [CPBezierPath bezierPathWithRoundedRect:bounds xRadius:radius yRadius:radius];
	[bp setLineWidth:2];
	[[CPColor whiteColor] set];	
	[bp fill];	
	
	var context = [[CPGraphicsContext currentContext] graphicsPort];

	// Clip the context and draw the heading gradient.
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + radius);
	CGContextAddArc(context, bounds.origin.x + radius, bounds.origin.y + radius, radius, -PI, -PI_2, YES);
	CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y);
	CGContextAddArc(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y + radius, radius, -PI_2, 0, YES);
	CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
	CGContextAddLineToPoint(context, bounds.origin.x, bounds.origin.y + bounds.size.height);
	CGContextClip(context);	
	[CMColumnEditorHeadingGradient drawInRect:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, headerHeight) angle:90];
	CGContextRestoreGState(context);
	
	// Draw a pinstripe below the header
	[[CPColor lightGrayColor] set];
	CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y + headerHeight, bounds.size.width, 1));
	
	// Draw the border.
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + radius);
	CGContextAddArc(context, bounds.origin.x + radius, bounds.origin.y + radius, radius, -PI, -PI_2, YES);
	CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y);
	CGContextAddArc(context, bounds.origin.x + bounds.size.width - radius, bounds.origin.y + radius, radius, -PI_2, 0, YES);
	CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
	CGContextAddLineToPoint(context, bounds.origin.x, bounds.origin.y + bounds.size.height);
	CGContextClosePath(context);
	[[CPColor darkGrayColor] set];
	CGContextSetLineWidth(context, 2);
	CGContextStrokePath(context);
}

- (IBAction)done:(id)sender {
	[mainView closeValueEditor];
}

- (IBAction)selectSegment:(id)sender {
	[self setSelectedSegment:[segments selectedSegment]];
}

@end
