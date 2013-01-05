//
//  CCCheckbox.m
//  CCardX
//
//  Created by Jim Hamilton on 8/19/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCCheckbox.m,v 1.4 2010/12/21 05:13:27 jimh Exp $

#import "CCCheckbox.h"

@implementation CCCheckbox

@synthesize parent;

- (BOOL) debugMode {
    return [[self cell] debugMode];
}
- (void) setDebugMode:(BOOL) newDebugMode {
    [[self cell] setDebugMode:newDebugMode];
}

- (void) setColor:(NSColor *)aColor {
    color = aColor;
    
    if (nil == [self cell]) return;
    [[self cell] setColor:aColor];
}
- (NSColor *) getColor {
    return color;
}

- (void) setColorKey:(NSString *)key {
    [[self cell] setColorKey:key];
}

+ (id) cellClass {
    return [CCCheckboxCell class];
}

- (id) initWithFrameUnscaled:(NSRect)frameRect {
    unscaled = YES;
    return [self initWithFrame:frameRect];
}

- (id) initWithFrame:(NSRect)frameRect {
    NSNumber *scaleO = [[NSUserDefaults standardUserDefaults] objectForKey:ccDefaultScale];
    double initialScale = 1.0 * SCALE_MULT;
    if (scaleO && !unscaled) {
        initialScale = [scaleO doubleValue] / SCALE_MULT;
        frameRect.origin.x *= initialScale;
        frameRect.origin.y *= initialScale; 
        frameRect.size.width *= initialScale;
        frameRect.size.height *= initialScale;
    }
    
    if (self = [super initWithFrame:frameRect]) {
        frame = frameRect;
        [self setButtonType:NSOnOffButton];
        [[self cell] setColorKey:ccNormalColor];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect color:(NSColor *)aColor {
    if ([self initWithFrame:frameRect]) {
        [self setColor:aColor];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect colorKey:(NSString *)aColorKey {
    if ([self initWithFrame:frameRect]) {
        [[self cell] setColorKey:aColorKey];
    }
    return self;
}

- (void) setDName:(NSString *)aName {
    [[self cell] setDName:aName];
}

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget {
    BOOL retv = [super sendAction:theAction to:theTarget];
    
    if (parent) 
        [parent notify:self];
    
    return retv;
}

    // don't take keyboard input
- (BOOL) acceptsFirstResponder {
    return NO;
}

@end
