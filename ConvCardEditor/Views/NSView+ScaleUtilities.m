//
//  NSView+ScaleUtilities.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/9/13.
//  Stolen from https://developer.apple.com/library/mac/#qa/qa2004/qa1346.html
//

#import "NSView+ScaleUtilities.h"
#import "CommonStrings.h"

static void scaleSubviews(NSArray *sViews, double scaleRatio) {
    for (NSView *sv in sViews) {
        NSRect fr = [sv frame];
        fr.origin.x *= scaleRatio;
        fr.origin.y *= scaleRatio;
        fr.size.width *= scaleRatio;
        fr.size.height *= scaleRatio;
        [sv setFrame:fr];
        NSArray *more = [sv subviews];
        if (more && [more count])
            scaleSubviews(more, scaleRatio);
    }
}

@implementation NSView (ScaleUtilities)

static const NSSize unitSize = {1.0, 1.0};

    // Returns the scale of the receiver's coordinate system, relative to the window's base coordinate system.
- (CGFloat)scale;
{
    return [self convertSize:unitSize toView:nil].width;
}

    // Sets the scale in absolute terms.
- (void)setScale:(CGFloat)newScale;
{
    [self resetScaling]; // First, match our scaling to the window's coordinate system
    [self scaleUnitSquareToSize:NSMakeSize(newScale, newScale)]; // Then, set the scale.
    [self setNeedsDisplay:YES]; // Finally, mark the view as needing to be redrawn
}

    // Makes the scaling of the receiver equal to the window's base coordinate system.
- (void)resetScaling;
{
    [self scaleUnitSquareToSize:[self convertSize:unitSize fromView:nil]];
}

- (void)scaleTo:(CGFloat)linearScale
{
        // set through the scale property
    self.scale = linearScale;
}

- (void)scaleBy:(CGFloat)ratio
{
    [self setFrame:[NSView scaleRect:self.frame by:ratio]];
}

- (void)deepScaleBy:(CGFloat)ratio
{
    [self scaleBy:ratio];
    [self.subviews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        [view scaleBy:ratio];
    }];
}

+ (NSRect)scaleRect:(NSRect)rect by:(CGFloat)ratio
{
    rect.origin.x *= ratio;
    rect.origin.y *= ratio;
    rect.size.width *= ratio;
    rect.size.height *= ratio;

    return rect;
}

+ (CGFloat)defaultScale
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:ccDefaultScale];
}

+ (NSRect)defaultScaleRect:(NSRect)rect
{
    return [self scaleRect:rect by:[self defaultScale]];
}

@end
