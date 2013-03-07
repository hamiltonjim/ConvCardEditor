//
//  NSView+ScaleUtilities.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/9/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (ScaleUtilities)

/*
    Change scale by the given ratio.
 */
- (void)scaleBy:(CGFloat)ratio;     // self only
- (void)deepScaleBy:(CGFloat)ratio; // self and subviews

    // scaling from model to scaled view
+ (NSRect)scaleRect:(NSRect)rect by:(CGFloat)ratio;
+ (NSPoint)scalePoint:(NSPoint)point by:(CGFloat)ratio;

+ (CGFloat)defaultScale;
+ (NSRect)defaultScaleRect:(NSRect)rect;
+ (NSPoint)defaultScalePoint:(NSPoint)point;

    // convenience: from scaled view to model must be the reciprocal
+ (NSRect)unscaleRect:(NSRect)rect by:(CGFloat)ratio;
+ (NSPoint)unscalePoint:(NSPoint)point by:(CGFloat)ratio;

+ (CGFloat)defaultUnscale;
+ (NSRect)defaultUnscaleRect:(NSRect)rect;
+ (NSPoint)defaultUnscalePoint:(NSPoint)point;

@end
