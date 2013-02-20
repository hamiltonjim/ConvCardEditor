//
//  NSView+ScaleUtilities.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/9/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (ScaleUtilities)

@property (assign) CGFloat scale;

- (void)resetScaling;

/*
 Set the scale to both height and width (i.e., squarely).
 */
- (void)scaleTo:(CGFloat)linearScale;

/*
    Change scale by the given ratio.
 */
- (void)scaleBy:(CGFloat)ratio;     // self only
- (void)deepScaleBy:(CGFloat)ratio; // self and subviews

+ (NSRect)scaleRect:(NSRect)rect by:(CGFloat)ratio;

+ (CGFloat)defaultScale;
+ (NSRect)defaultScaleRect:(NSRect)rect;

@end
