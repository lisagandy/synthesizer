/*
 * CMMainView.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on November 28, 2013.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMMainView : CPView
{
	CGPoint originalClickInWindow;
	CGRect originalFrame;

	CPTextField label;
}

- (id)initWithFrame:(CGRect)aFrame {
	self = [super initWithFrame:aFrame];
	if (self) {
	} 
	return self;
}

- (void)drawRect:(CGRect)rect {
	var bounds = [self bounds]; 
	var context = [[CPGraphicsContext currentContext] graphicsPort]; 

	CGContextSetFillColor(context, [CPColor purpleColor]); 
	CGContextFillRect(context, CGRectMake(bounds.origin.x + 5, bounds.origin.y + 5, bounds.size.width - 10., bounds.size.height - 10.)); 
}

/*
// mouse movement handler
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
