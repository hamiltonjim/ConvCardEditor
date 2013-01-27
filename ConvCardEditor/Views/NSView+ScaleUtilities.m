//
//  NSView+ScaleUtilities.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/9/13.
//  Stolen from https://developer.apple.com/library/mac/#qa/qa2004/qa1346.html
//

#import "NSView+ScaleUtilities.h"

@implementation NSView (ScaleUtilities)

static const NSSize unitSize = {1.0, 1.0};

    // Returns the scale of the receiver's coordinate system, relative to the window's base coordinate system.
- (NSSize)scale;
{
    return [self convertSize:unitSize toView:nil];
}

    // Sets the scale in absolute terms.
- (void)setScale:(NSSize)newScale;
{
    [self resetScaling]; // First, match our scaling to the window's coordinate system
    [self scaleUnitSquareToSize:newScale]; // Then, set the scale.
    [self setNeedsDisplay:YES]; // Finally, mark the view as needing to be redrawn
}

    // Makes the scaling of the receiver equal to the window's base coordinate system.
- (void)resetScaling;
{
    [self scaleUnitSquareToSize:[self convertSize:unitSize fromView:nil]];
}

- (double)wScale
{
    return self.scale.width;
}

- (double)hScale
{
    return self.scale.height;
}

- (void)scaleTo:(double)linearScale
{
        // set through the scale property
    self.scale = NSMakeSize(linearScale, linearScale);
}

@end
