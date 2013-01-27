//
//  CCBoxMatrix.m
//  CCardX
//
//  Created by Jim Hamilton on 8/20/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCBoxMatrix.m,v 1.3 2010/11/01 03:25:21 jimh Exp $

#import <Foundation/NSObjCRuntime.h>
#import "CCBoxMatrix.h"
#import "CCCheckbox.h"

#import "CommonStrings.h"
#import "AppDelegate.h"

static NSRect 
matrixUnionRect(NSArray *exes, NSArray *wyes, double sideW, double sideH) {
    NSRect result = NSMakeRect(0.0, 0.0, 0.0, 0.0); // empty
    
    for (NSNumber *theY in wyes) {
        double yval = [theY doubleValue];
        for (NSNumber *theX in exes) {
            double xval = [theX doubleValue];
            NSRect arect = NSMakeRect(xval, yval, sideW, sideH);
            result = NSUnionRect(result, arect);
        }
    }
    
    return result;
}

@interface CCBoxMatrix ()

- (void)placeChildControlsInRects:(NSArray *)rects;
- (void)setCellColors:(NSArray *)colorVals;

- (void)appendChild:(NSControl <CCDebuggableControl> *)appendChild;

@property (readwrite, weak) NSControl *selected;

@end

@implementation CCBoxMatrix


- (void) placeChildControlsInRects:(NSArray *)rects {
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[rects count]];
    NSInteger ctr = 0;
    
    for (NSValue *rv in rects) {
            // rect was given in absolute coordinates; convert to the matrix control's coordinates
        NSRect theRect = [self convertRect:[rv rectValue] fromView:[self superview]];
        CCCheckbox *cbox = [[CCCheckbox alloc] initWithFrame:theRect];
        [self addSubview:cbox];
        [cbox setParent:self];
        [tmpArray addObject:cbox];
        [cbox setTag:ctr++];
    }
    
    self.controls = tmpArray;
}

- (void) setCellColors:(NSArray *)colorVals {
    id object;
        // array (cols) of arrays (rows) of colors...
    NSArray *colors = nil;
    NSColor *uniformColor = nil;
    NSString *uniformKey = nil;
    
    if (!colorVals || 0 == [colorVals count])
        uniformKey = ccNormalColor;
    else if (1 == [colorVals count]) {
        object = [colorVals objectAtIndex:0];
        if ([object isKindOfClass:[NSString class]])
            uniformKey = (NSString *)object;
        else if ([object isKindOfClass:[NSColor class]])
            uniformColor = (NSColor *)object;
    } else 
        colors = colorVals;
    
        // if there's a uniform color, apply it to all (and we're done!)
    if (uniformKey) {
        for (CCCheckbox *actrl in self.controls) {
            [actrl setColorKey:uniformKey];
        }
        return;
    }
    if (uniformColor) {
        for (CCCheckbox *actrl in self.controls) {
            [actrl setColor:uniformColor];
        }
        return;
    }
    
        // otherwise, apply in order; count of colors MUST match count of controls
    NSInteger nEntries = [self.controls count];
    if ([colorVals count] != nEntries) {
        NSLog(@"Can't set %ld colors to %ld controls; %@ %@", [colorVals count],
              nEntries, NSStringFromClass([self class]), self.name);
    }
    
    NSEnumerator *controlEnum = [self.controls objectEnumerator];
    NSEnumerator *colorEnum = [colorVals objectEnumerator];
    CCCheckbox *ckbox;
    NSColor *color;
    while ((ckbox = [controlEnum nextObject]) != nil && (color = [colorEnum nextObject]) != nil) {
        if ([color isKindOfClass:[NSString class]])
            [ckbox setColorKey:(NSString *)color];
        else if ([color isKindOfClass:[NSColor class]])
            [ckbox setColor:(NSColor *)color];

    }
}


    // pass an array of just one color to use the same color for all 
    // cells; pass nil array to use black for all
- (id) initWithRects:(NSArray *)rects colors:(NSArray *)colors name:(NSString *)matrixName {
    if (!rects || 0 == [rects count])
        [NSException raise:@"badParams" 
                    format:@"Invalid parameters for %@:  rects %@ colors %@",
         NSStringFromClass([self class]), rects, colors];
    
    NSRect bounds = NSZeroRect;
    for (NSValue *ct in rects) {
        bounds = NSUnionRect(bounds, [ct rectValue]);
    }
    
    if (self = [super initWithFrame:bounds name:matrixName]) {
        [self placeChildControlsInRects:rects];
        
        [self setCellColors:colors];
        [self setAllowsEmptySelection:YES];
        self.selected = nil;
    }
    
    return self;
}

- (void)appendChild:(NSControl<CCDebuggableControl> *)child
{
    NSRect rect = [child convertRect:[child frame] toView:self];
    [self setFrame:NSUnionRect([self frame], rect)];
    [self addSubview:child];
    [self.controls addObject:child];
}

- (void)addChildControl:(CCCheckbox *)child
{
    [self appendChild:child];
}

- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color
{
    CCCheckbox *cbox = [[CCCheckbox alloc] initWithFrame:rect color:color];
    [self appendChild:cbox];
}

- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode
{
    NSString *colorKey = [[AppDelegate instance] colorKeyForCode:colorCode];
    [self placeChildInRect:rect withColorKey:colorKey];
}

- (void)placeChildInRect:(NSRect)rect withColorKey:(NSString *)colorKey
{
    CCCheckbox *cbox = [[CCCheckbox alloc] initWithFrame:rect colorKey:colorKey];
    [self appendChild:cbox];
}

@end
