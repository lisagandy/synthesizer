/*
 * CMScroller.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez on April 30, 2014.
 * Copyright 2013, Gaucho Software, LLC.  All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CMScroller : CPScroller
{
}

- (void)fadeOut {
    if ([self hasThemeState:CPThemeStateScrollViewLegacy])
        return;
    if (![[self target] autohidesScrollers]) 
	    return;

    [_animationScroller startAnimation];
}

@end
