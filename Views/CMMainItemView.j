/*
 * CMMainItemView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 30, 2014.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../Model/CMColumnManager.j"

@implementation CMMainItemView : CPView
{
/*
	CGPoint originalClickInWindow;
	CGRect originalFrame;
	
*/
	CPTextField label;
	CPTextField countLabel;
	
	BOOL selected @accessors;
	CPGradient selectedGradient;
	CPGradient deselectedGradient;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		// Blue
		//selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithRed:0.391 green:0.656 blue:0.891 alpha:1.000] endingColor:[CPColor colorWithRed:0.190 green:0.436 blue:0.778 alpha:1.000]];
		// Gray
		selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.4 alpha:1] endingColor:[CPColor colorWithWhite:0.55 alpha:1]];
		deselectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.92 alpha:1] endingColor:[CPColor colorWithWhite:1 alpha:1]];
	} 
	return self;
}

- (id)initWithCoder:(CPCoder)aCoder {
	self = [super initWithCoder:aCoder];
	if (self) {
		// Blue
		//selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithRed:0.391 green:0.656 blue:0.891 alpha:1.000] endingColor:[CPColor colorWithRed:0.190 green:0.436 blue:0.778 alpha:1.000]];
		// Gray
		selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.4 alpha:1] endingColor:[CPColor colorWithWhite:0.55 alpha:1]];
		deselectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.92 alpha:1] endingColor:[CPColor colorWithWhite:1 alpha:1]];
		label = [aCoder decodeObjectForKey:@"Label"];
		countLabel = [aCoder decodeObjectForKey:@"CountLabel"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeConditionalObject:label forKey:@"Label"];
	[aCoder encodeConditionalObject:countLabel forKey:@"CountLabel"];
}

- (void)setSelected:(BOOL)isSelected {
	selected = isSelected;
/*
	[label setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor blackColor])];
	[countLabel setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor grayColor])];
	[self setNeedsDisplay:YES];
*/
}

- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	CGContextSetFillColor(context, [CPColor whiteColor]); 
	CGContextFillRect(context, bounds); 
}

- (void)setRepresentedObject:(id)anObject {
	// anObject is of type CMColumn.
	
	if (!label) {
		label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 10.0, 0)];
		[label setFont:[CPFont boldSystemFontOfSize:14.0]];
		[label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[label setVerticalAlignment:CPCenterVerticalTextAlignment];
		[self addSubview:label];
	}
	
	[label setStringValue:[anObject name]];
}

@end
