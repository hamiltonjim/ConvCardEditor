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
#import "CCEMultiCheckModel.h"

@interface CCLeadChoiceMatrix ()

@property (readwrite, weak) NSControl *selected;

@end


@implementation CCLeadChoiceMatrix

@synthesize selected;

- (NSControl <CCDebuggableControl> *)createChildInRect:(NSRect)theRect
{
    return [[CCLeadChoice alloc] initWithFrame:theRect];
}

    // Pass an array of just one color to use the same color for all
    // Pass rectangles containing individual ovals
- (id)initWithRects:(NSArray *)rects name:(NSString *)matrixName;
{
    return [self initWithFrame:NSZeroRect rects:rects name:matrixName];
}

- (id)initWithFrame:(NSRect)frameRect rects:(NSArray *)rects name:(NSString *)matrixName
{
    if (!rects || 0 == [rects count]) {
        [NSException raise:@"badParams"
                    format:@"Invalid parameters for %@:  rects %@ ",
         NSStringFromClass([self class]), rects];
    }
    
    NSRect bounds = frameRect;
    for (NSValue *ct in rects) {
        bounds = NSUnionRect(bounds, [ct rectValue]);
    }
    
        // When adding component rects, there is a possibility that rounding can truncate
        // the rightmost choice circle.  Just add 1.0 to the bounds width to prevent this...
    ++bounds.size.width;
    
    if (self = [super initWithFrame:bounds name:matrixName]) {
        [self placeChildControlsInRects:rects];
        
        [self setAllowsEmptySelection:YES];
        selected = nil;
    }
    
    return self;
}

- (id)initWithModel:(CCEMultiCheckModel *)model
{
    return [self initWithModel:model insideRect:NSZeroRect];
}
- (id)initWithModel:(CCEMultiCheckModel *)model insideRect:(NSRect)rect
{
    NSSet *locations = model.locations;
    NSUInteger count = locations.count;
    
    NSMutableArray *rectArray = [NSMutableArray arrayWithCapacity:count];
        // prefill with null objects; they will be replaced
    for (NSUInteger index = 0; index < count; ++index) {
        [rectArray addObject:[NSNull null]];
    }

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
        
    }];
    
    if ((self = [self initWithFrame:rect rects:rectArray name:model.name])) {
        self.modelledControl = model;
    }
    return self;
}

+ (CCLeadChoiceMatrix *)matrixWithModel:(CCEMultiCheckModel *)model
{
    return [[CCLeadChoiceMatrix alloc] initWithModel:model];
}
+ (CCLeadChoiceMatrix *)matrixWithModel:(CCEMultiCheckModel *)model insideRect:(NSRect)rect
{
    return [[CCLeadChoiceMatrix alloc] initWithModel:model insideRect:rect];
}

    // colors objects are ignored
- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color
{
    CCLeadChoice *cbox = [[CCLeadChoice alloc] initWithFrame:rect];
    [self addChildControl:cbox];
}

- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode
{
        // ignoring colors, define in terms of above
    [self placeChildInRect:rect withColor:nil];
}

    // name for display purpose
- (NSString *)shapeName:(NSInteger)nounCase
{
    if (kPossessive == nounCase) {
        return NSLocalizedString(@"oval's", @"display name of a lead choice oval, possessive case");
    } else {
        return NSLocalizedString(@"oval", @"display name of a lead choice oval, nominative case");
    }
}

@end
