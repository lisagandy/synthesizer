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
	CPTextField label;
	CPTextField detailLabel;
		
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
		//selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.4 alpha:1] endingColor:[CPColor colorWithWhite:0.55 alpha:1]];
		//deselectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.92 alpha:1] endingColor:[CPColor colorWithWhite:1 alpha:1]];
	} 
	return self;
}

- (id)initWithCoder:(CPCoder)aCoder {
	self = [super initWithCoder:aCoder];
	if (self) {
		// Blue
		//selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithRed:0.391 green:0.656 blue:0.891 alpha:1.000] endingColor:[CPColor colorWithRed:0.190 green:0.436 blue:0.778 alpha:1.000]];
		// Gray
		//selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.4 alpha:1] endingColor:[CPColor colorWithWhite:0.55 alpha:1]];
		//deselectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:0.92 alpha:1] endingColor:[CPColor colorWithWhite:1 alpha:1]];
		label = [aCoder decodeObjectForKey:@"Label"];
		detailLabel = [aCoder decodeObjectForKey:@"DetailLabel"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeConditionalObject:label forKey:@"Label"];
	[aCoder encodeConditionalObject:detailLabel forKey:@"DetailLabel"];
}

- (void)setSelected:(BOOL)isSelected {
	selected = isSelected;

/*
	[label setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor blackColor])];
	[detailLabel setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor grayColor])];
	[self setNeedsDisplay:YES];
*/
}

- (void)layoutSubviews {
	var bounds = [self bounds];
	[label setFrame:CGRectMake(bounds.origin.x + 10., bounds.origin.y, bounds.size.width - 20., bounds.size.height * .6)];
	[detailLabel setFrame:CGRectMake(bounds.origin.x + 10., bounds.origin.y + (bounds.size.height * .6), bounds.size.width - 20., bounds.size.height * .4)];
}

/*
- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	CGContextSetFillColor(context, [CPColor whiteColor]); 
	CGContextFillRect(context, bounds); 
}
*/

- (void)setObjectValue:(id)anObject {
	[self setRepresentedObject:anObject];
}

- (void)setRepresentedObject:(id)anObject {
	// anObject is of type CMColumn.
	var bounds = [self bounds];
		
	if (!label) {
		label = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x + 10., bounds.origin.y, bounds.size.width - 20., bounds.size.height * .6)];
		[label setFont:[CPFont boldSystemFontOfSize:14.0]];
		[label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[label setVerticalAlignment:CPBottomVerticalTextAlignment];
		[self addSubview:label];
	}
	
	if (!detailLabel) {
		detailLabel = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x + 10., bounds.origin.y + (bounds.size.height * .6), bounds.size.width - 20., bounds.size.height * .4)];
		[detailLabel setFont:[CPFont systemFontOfSize:10.0]];
		[detailLabel setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		[detailLabel setVerticalAlignment:CPTopVerticalTextAlignment];
		[self addSubview:detailLabel];
	}
		
	[label setStringValue:[anObject name]];
	[detailLabel setStringValue:[anObject spreadsheet]];
}

- (BOOL)setThemeState:(CPThemeState)state {
	[self setSelected:YES];
	return YES;
}

- (BOOL)unsetThemeState:(CPThemeState)state {
	[self setSelected:NO];
	return YES;
}

@end
