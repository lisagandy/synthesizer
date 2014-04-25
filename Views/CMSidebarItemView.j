/*
 * CMSidebarItemView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMSidebarItemView : CPView
{
/*
	CGPoint originalClickInWindow;
	CGRect originalFrame;
	
*/
	CPTextField label;
	
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
		label = [aCoder decodeObjectForKey:@"TextField"];
	}
	return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeConditionalObject:label forKey:@"TextField"];
}

- (void)setSelected:(BOOL)isSelected {
	selected = isSelected;
	[label setTextColor:(isSelected ? [CPColor whiteColor] : [CPColor blackColor])];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

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

	[label setStringValue:[anObject name]];

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
