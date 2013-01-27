//
//  CCLeadChoiceMatrix.m
//  CCardX
//
//  Created by Jim Hamilton on 8/28/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCLeadChoiceMatrix.m,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import "CCLeadChoiceMatrix.h"
#import "CCLeadChoice.h"

@interface CCLeadChoiceMatrix ()

- (void)placeChildControlsInRects:(NSArray *)cRects;
- (void)appendChild:(NSControl <CCDebuggableControl> *)appendChild;

@property (readwrite, weak) NSControl *selected;

@end


@implementation CCLeadChoiceMatrix

- (void)placeChildControlsInRects:(NSArray *)cRects
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[cRects count]];
    NSInteger ctr = 0;
    
    for (NSValue *rv in cRects) {
        NSRect frm = [self convertRect:[rv rectValue] fromView:[self superview]];
        CCLeadChoice *cbox = [[CCLeadChoice alloc] initWithFrame:frm];
        [self addSubview:cbox];
        [cbox setParent:self];
        [tmpArray addObject:cbox];
        [cbox setTag:++ctr];
    }
    
    self.controls = tmpArray;
}

    // Pass an array of just one color to use the same color for all
    // Pass rectangles containing individual ovals
- (id)initWithRects:(NSArray *)rects name:(NSString *)matrixName;
{
    if (!rects || 0 == [rects count]) {
        [NSException raise:@"badParams"
                    format:@"Invalid parameters for %@:  rects %@ ",
         NSStringFromClass([self class]), rects];
    }
    
    NSRect bounds = NSZeroRect;
    for (NSValue *ct in rects) {
        bounds = NSUnionRect(bounds, [ct rectValue]);
    }
    
    if (self = [super initWithFrame:bounds name:matrixName]) {
        [self placeChildControlsInRects:rects];
        
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

- (void)addChildControl:(NSControl <CCDebuggableControl> *)child
{
    [self appendChild:child];
}


    // colors objects are ignored
- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color
{
    CCLeadChoice *cbox = [[CCLeadChoice alloc] initWithFrame:rect];
    [self appendChild:cbox];
}

- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode
{
        // ignoring colors, define in terms of above
    [self placeChildInRect:rect withColor:nil];
}

- (void)setDebugMode:(int)newDebugMode
{
    for (NSControl <CCDebuggableControl> *ctrl in self.controls) {
        [ctrl setDebugMode:newDebugMode];
    }
}

@end
