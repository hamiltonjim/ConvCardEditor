//
//  NSView+ScaleUtilities.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/9/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (ScaleUtilities)

@property (assign) NSSize scale;

- (void)resetScaling;

/*
 When the scale is known to be "square" (that is, relative scaling is
 the same), it might be more convenient at times to just get one of
 the dimensions.
 */
- (double)wScale;
- (double)hScale;

/*
 Set the scale to both height and width (i.e., squarely).
 */
- (void)scaleTo:(double)linearScale;

@end
