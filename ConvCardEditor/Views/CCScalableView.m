//
//  CCScalableView.m
//  CCardX
//
//  Created by Jim Hamilton on 10/17/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCScalableView.m,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import "CCScalableView.h"
#import "AppDelegate.h"
#import "fuzzyMath.h"
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


@implementation CCScalableView


- (double) scale {
    return scale;
}
- (void) setScale:(double) newscale {
    double oldscale = scale;
    scale = newscale;
    if (0 == fuzzyCompare(oldscale, newscale))
        return;
    
    double chg = scale / oldscale;
    
    bounds.size.width *= chg;
    bounds.size.height *= chg;
    [self setFrameSize:bounds.size];
    
    scaleSubviews([self subviews], chg);
    
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSNumber *scaleO = [[NSUserDefaults standardUserDefaults] objectForKey:ccDefaultScale];
        if (scaleO)
            scale = [scaleO doubleValue] / SCALE_MULT;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

@end
