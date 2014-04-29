/*
 * CMSidebarItemView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../Model/CMColumnManager.j"

@implementation CMSidebarItemView : CPView
{
/*
	CGPoint originalClickInWindow;
	CGRect originalFrame;
	
*/
	CPTextField label;
	CPTextField countLabel;
	
	BOOL selected @accessors;
	CPGradient selectedGradient;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
		selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithRed:0.391 green:0.656 blue:0.891 alpha:1.000] endingColor:[CPColor colorWithRed:0.190 green:0.436 blue:0.778 alpha:1.000]];
	} 
	return self;
}

- (id)initWithCoder:(CPCoder)aCoder {
	self = [super initWithCoder:aCoder];
	if (self) {
		selectedGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithRed:0.391 green:0.656 blue:0.891 alpha:1.000] endingColor:[CPColor colorWithRed:0.190 green:0.436 blue:0.778 alpha:1.000]];
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
	[label setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor blackColor])];
	[countLabel setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor grayColor])];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	// Below in setRepresentedObject, we might have a 0 bounds, so reposition the counter label here so it shows up in the correct spot.
	[countLabel setFrame:CGRectMake(bounds.origin.x + bounds.size.width - 10. - 30., bounds.origin.y, 30., bounds.size.height)];

	if (selected) {
		[selectedGradient drawInRect:bounds angle:90];
	}
	else {
		CGContextSetFillColor(context, [CPColor whiteColor]); 
		CGContextFillRect(context, bounds); 
	}
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
	
	if (!countLabel) {
		var bounds = [self bounds];
		countLabel = [[CPTextField alloc] initWithFrame:CGRectMake(bounds.origin.x + bounds.size.width - 10. - 30., bounds.origin.y, 30., bounds.size.height)];
		[countLabel setFont:[CPFont systemFontOfSize:11.0]];
		[countLabel setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable | CPViewMinXMargin];
		[countLabel setAlignment:CPCenterTextAlignment];
		[countLabel setVerticalAlignment:CPCenterVerticalTextAlignment];
		[countLabel setTextColor:[CPColor grayColor]];
		[self addSubview:countLabel];
	}

	[label setStringValue:[anObject name]];
	var equivalentCount = [[[CMColumnManager sharedManager] equivalentsForColumn:anObject] count];
	[countLabel setStringValue:equivalentCount > 0 ? [CPString stringWithFormat:@"%d", equivalentCount] : @""];

/*
	if (!_imageView) {
		_imageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 5.0, 5.0)];
		
		[_imageView setImageScaling:CPScaleProportionally];
		[_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
		
		[self addSubview:_imageView];
	}
	
	[_imageView setImage:anObject];
*/
}


// mouse movement handler
/*
- (void)mouseDown:(CPEvent)anEvent {
	originalClickInWindow = [anEvent locationInWindow];
	originalFrame = [self frame];

	[self setBackgroundColor:[CPColor orangeColor]];
}
 
// on mouse move, we construct a visual hovering effect.     
- (void)mouseDragged:(CPEvent)anEvent {
	var currentLocationInWindow = [anEvent locationInWindow];
	var offset = CGPointMakeZero();
	offset.x = originalClickInWindow.x - currentLocationInWindow.x;
	offset.y = originalClickInWindow.y - currentLocationInWindow.y;

	[self setFrame:CPRectMake(originalFrame.origin.x - offset.x, originalFrame.origin.y - offset.y, originalFrame.size.width, originalFrame.size.height)];
}

- (void)mouseUp:(CPEvent)anEvent {
	[self setBackgroundColor:[CPColor yellowColor]];
}
*/

@end
