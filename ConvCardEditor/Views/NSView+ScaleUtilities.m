//
//  NSView+ScaleUtilities.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/9/13.
//  Stolen from https://developer.apple.com/library/mac/#qa/qa2004/qa1346.html
//

#import "NSView+ScaleUtilities.h"
#import "CommonStrings.h"
#import "CCEScalableTextField.h"

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
    NSRect frm = [NSView scaleRect:self.frame by:ratio];
    
    if ([self respondsToSelector:@selector(setFrame:forRescaling:)]) {
        [(id)self setFrame:frm forRescaling:YES];
    } else {
        [self setFrame:frm];
    }
}

- (void)deepScaleBy:(CGFloat)ratio
{
    [self scaleBy:ratio];
    [self.subviews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        [view deepScaleBy:ratio];
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

+ (NSPoint)scalePoint:(NSPoint)point by:(CGFloat)ratio
{
    point.x *= ratio;
    point.y *= ratio;
    
    return point;
}

+ (CGFloat)defaultScale
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:ccDefaultScale];
}

+ (NSRect)defaultScaleRect:(NSRect)rect
{
    return [self scaleRect:rect by:[self defaultScale]];
}

+ (NSPoint)defaultScalePoint:(NSPoint)point
{
    return [self scalePoint:point by:[self defaultScale]];
}

+ (NSRect)unscaleRect:(NSRect)rect by:(CGFloat)ratio
{
    return [self scaleRect:rect by:(1.0 / ratio)];
}

+ (NSPoint)unscalePoint:(NSPoint)point by:(CGFloat)ratio
{
    return [self scalePoint:point by:(1.0 / ratio)];
}

+ (CGFloat)defaultUnscale
{
    return 1.0 / [self defaultScale];
}

+ (NSRect)defaultUnscaleRect:(NSRect)rect
{
    return [self scaleRect:rect by:[self defaultUnscale]];
}

+ (NSPoint)defaultUnscalePoint:(NSPoint)point
{
    return [self scalePoint:point by:[self defaultUnscale]];
}

@end
