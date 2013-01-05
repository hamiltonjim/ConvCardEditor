//
//  CCBoxView.m
//  CCardX
//
//  Created by Jim Hamilton on 12/20/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//

#import "CCBoxView.h"


@implementation CCBoxView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSBezierPath *box = [NSBezierPath bezierPathWithRect:[self bounds]];
    [[NSColor blackColor] set];
    [box stroke];
}

@end
