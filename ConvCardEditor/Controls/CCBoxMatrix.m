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
#import "CCEMultiCheckModel.h"
#import "CommonStrings.h"
#import "AppDelegate.h"

static NSRect 
matrixUnionRect(NSArray *exes, NSArray *wyes, double sideW, double sideH) {
    NSRect result = NSZeroRect; // empty
    
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

- (void)setCellColors:(NSArray *)colorVals;

@property (readwrite, weak) NSControl *selected;

@end

@implementation CCBoxMatrix

- (NSControl <CCDebuggableControl> *)createChildInRect:(NSRect)theRect
{
    return [[CCCheckbox alloc] initWithFrame:theRect];
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
    NSEnumerator *colorEnum = [colors objectEnumerator];
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
- (id)initWithRects:(NSArray *)rects
             colors:(NSArray *)colors
               name:(NSString *)matrixName
{
    if (!rects || 0 == [rects count])
        [NSException raise:@"badParams" 
                    format:@"Invalid parameters for %@:  rects %@ colors %@",
         NSStringFromClass([self class]), rects, colors];
    
    return [self initWithFrame:NSZeroRect rects:rects colors:colors name:matrixName];
}

- (id)initWithFrame:(NSRect)frameRect
              rects:(NSArray *)rects
             colors:(NSArray *)colors
               name:(NSString *)matrixName
{
    NSRect bounds = frameRect;
    for (NSValue *ct in rects) {
        bounds = NSUnionRect(bounds, [ct rectValue]);
    }
    
    if (self = [super initWithFrame:bounds name:matrixName]) {
        [self placeChildControlsInRects:rects];
        
        [self setCellColors:colors];
        [self setAllowsEmptySelection:YES];
    }
    
    return self;
}

- (id)initWithModel:(CCEMultiCheckModel *)model
{
    return [self initWithModel:model insideRect:NSZeroRect];
}
- (id)initWithModel:(CCEMultiCheckModel *)model insideRect:(NSRect)frame
{
    NSSet *locations = model.locations;
    NSUInteger count = locations.count;

    NSMutableArray *rectArray = [NSMutableArray arrayWithCapacity:count];
        // prefill with null objects; they will be replaced
    for (NSUInteger index = 0; index < count; ++index) {
        [rectArray addObject:[NSNull null]];
    }
        // also need array for colors
    NSMutableArray *colorArray = [rectArray mutableCopy];
    
    [locations enumerateObjectsUsingBlock:^(CCELocation *loc, BOOL *stop) {
        NSUInteger lIndex = loc.index.integerValue;
        
            // indices start at 1, so correct, then check
        if (--lIndex >= count) {
            NSLog(@"%s line %d invalid index %ld > %ld in location %@ of model %@",
                  __FILE__, __LINE__,  lIndex, count, loc, model.name);
            return;
        }
        
        NSRect rect = NSMakeRect(loc.locX.doubleValue, loc.locY.doubleValue,
                                 loc.width.doubleValue, loc.height.doubleValue);
        [rectArray replaceObjectAtIndex:lIndex withObject:[NSValue valueWithRect:rect]];
        
        id colorObj;
        NSNumber *colorCodeObj = loc.colorCode; // code takes precedence over raw color...
        if (colorCodeObj == nil) {
            colorObj = loc.color;
        } else {
            colorObj = [(AppDelegate *)[NSApp delegate] colorKeyForCode:colorCodeObj.integerValue];
        }
        if (colorObj == nil) {  // still
            colorObj = ccNormalColor;
        }
        [colorArray replaceObjectAtIndex:lIndex withObject:colorObj];
    }];
    
    if ((self = [self initWithFrame:frame rects:rectArray colors:colorArray name:model.name])) {
        self.modelledControl = model;
    }
    return self;
}

+ (CCBoxMatrix *)matrixWithModel:(CCEMultiCheckModel *)model
{
    return [[CCBoxMatrix alloc] initWithModel:model];
}
+ (CCBoxMatrix *)matrixWithModel:(CCEMultiCheckModel *)model insideRect:(NSRect)rect
{
    return [[CCBoxMatrix alloc] initWithModel:model insideRect:rect];
}

- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color
{
    CCCheckbox *cbox = [[CCCheckbox alloc] initWithFrame:rect color:color];
    [self addChildControl:cbox];
}

- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode
{
    NSString *colorKey = [[AppDelegate instance] colorKeyForCode:colorCode];
    [self placeChildInRect:rect withColorKey:colorKey];
}

- (void)placeChildInRect:(NSRect)rect withColorKey:(NSString *)colorKey
{
    CCCheckbox *cbox = [[CCCheckbox alloc] initWithFrame:rect colorKey:colorKey];
    [self addChildControl:cbox];
}

    // name for display purpose
- (NSString *)shapeName:(NSInteger)nounCase
{
    if (kPossessive == nounCase) {
        return NSLocalizedString(@"checkbox's", @"display name of a checkbox, possessive case");
    } else {
        return NSLocalizedString(@"checkbox", @"display name of a checkbox, nominative case");
    }
}

@end
