//
//  NSView+CCEViewUtilities.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/18/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "NSView+CCEViewUtilities.h"

@implementation NSView (CCEViewUtilities)

- (void)moveByX:(CGFloat)xOffset andY:(CGFloat)yOffset
{
    NSPoint origin = self.frame.origin;
    origin.x += xOffset;
    origin.y += yOffset;
    
    [self setFrameOrigin:origin];
}

@end
