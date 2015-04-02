/*
 * CMHelpView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014-2015, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>


@implementation CMHelpView : CPView
{
	CPMainView mainView @accessors;
	CPTextField title;
	CPButton doneButton;

	CPWebView webView;
	
	var headerHeight;
	var radius;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		headerHeight = 39;
		radius = 5;
		
		// Give ourselves a shadow.
		self._DOMElement.style.boxShadow = "0px 5px 35px #666";
		
		var bounds = CPRectInset([self bounds], 2, 2);

		// Title
		title = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, headerHeight)];
		[title setFont:[CPFont systemFontOfSize:20.0]];
		[title setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin];
		[title setAlignment:CPCenterTextAlignment];
		[title setVerticalAlignment:CPCenterVerticalTextAlignment];
		[title setTextColor:[CPColor blackColor]];
		[title setStringValue:@"Help"];
		[self addSubview:title];

		// Web View
		webView = [[CPWebView alloc] initWithFrame:CGRectMake(bounds.origin.x, bounds.origin.y + headerHeight, bounds.size.width, bounds.size.height - headerHeight)];
		var html = "<h2>test</h2>";
		[webView setMainFrameURL:"help.html"];
		[webView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable]
//		[webView loadHTMLString:html];
		[self addSubview:webView];

		// Done Button
		doneButton = [[CPButton alloc] initWithFrame:CGRectMake(bounds.origin.x + bounds.size.width - 30, bounds.origin.y + 10, 20, 20)];
		[doneButton setBordered:NO];
		[doneButton setImage:[[CPImage alloc] initWithContentsOfFile:("Resources/close-circle.png") size:CPSizeMake(20, 20)]];
		[doneButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:("Resources/close-circle-highlighted.png") size:CPSizeMake(20, 20)]];
		[doneButton setTarget:self];
		[doneButton setAction:@selector(done:)];
		[doneButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
		[doneButton setButtonType:CPMomentaryChangeButton];
		[self addSubview:doneButton];

		[self setNeedsDisplay:YES];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	var bounds = CPRectInset([self bounds], 1, 1);
	
	var bp = [CPBezierPath bezierPathWithRoundedRect:bounds xRadius:radius yRadius:radius];
	[bp setLineWidth:2];
	[[CPColor whiteColor] set];	
	[bp fill];	
	
	var context = [[CPGraphicsContext currentContext] graphicsPort];

	[CMColumnEditorHeadingGradient drawInRect:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, headerHeight) angle:90];
	
	// Draw a pinstripe below the header
	[[CPColor lightGrayColor] set];
	CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y + headerHeight - 1, bounds.size.width, 1));
	
	// Draw the border.
	CGContextBeginPath(context);
	CGContextAddRect(context, bounds);
	[[CPColor darkGrayColor] set];
	CGContextSetLineWidth(context, 2);
	CGContextStrokePath(context);
}

- (IBAction)done:(id)sender {
	[mainView closeHelp];
}

@end
