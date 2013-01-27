//
//  CCEGradientView.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/26/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEGradientView.h"

@implementation CCEGradientView

@synthesize startingColor;
@synthesize endingColor;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.startingColor = [NSColor clearColor];
        self.endingColor = nil;
        self.angle = 270.0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect
{
    if (endingColor == nil || [startingColor isEqual:endingColor]) {
            // Fill view with a standard background color
        [startingColor set];
        NSRectFill(rect);
    }
    else {
            // Fill view with a top-down gradient
            // from startingColor to endingColor
        NSGradient* aGradient = [[NSGradient alloc]
                                 initWithStartingColor:startingColor
                                 endingColor:endingColor];
        [aGradient drawInRect:[self bounds] angle:angle];
    }
}

@end
