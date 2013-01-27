//
//  SelectionCounters.m
//  modified for ARC
//
//  Created by Jim Hamilton on 6/13/2005.
//  Copyright 2005 Jim Hamilton. All rights reserved.
//

#import "SelectionCounters.h"


@implementation JfhSelectionTransformer

+ (void)registerTransformer
{
    JfhSelectionTransformer *xform;
	
    // register nil selection transformer
    xform = [JfhNilSelectionTransformer new];
    [NSValueTransformer setValueTransformer:xform forName:@"JfhNilSelectionTransformer"];
	
    // register single selection transformer
    xform = [JfhSingleSelectionTransformer new];
    [NSValueTransformer setValueTransformer:xform forName:@"JfhSingleSelectionTransformer"];
	
    // register single selection transformer
    xform = [JfhNotSingleSelectionTransformer new];
    [NSValueTransformer setValueTransformer:xform forName:@"JfhNotSingleSelectionTransformer"];
	
    // register multi selection transformer
    xform = [JfhMultiSelectionTransformer new];
    [NSValueTransformer setValueTransformer:xform forName:@"JfhMultiSelectionTransformer"];
}

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (NSUInteger)selectionCount:(NSArray *)array
{
    if ([array respondsToSelector:@selector(count)])
        return [array count];
    else
        return -1;
}

@end

@implementation JfhNilSelectionTransformer

- (id)transformedValue:(id)value;
{
    if (nil == value) return [NSNumber numberWithBool:YES];
    else return [NSNumber numberWithBool:(0 == [self selectionCount:value])];
}

@end

@implementation JfhSingleSelectionTransformer

- (id)transformedValue:(id)value;
{
    if (nil == value) return [NSNumber numberWithBool:NO];
    else return [NSNumber numberWithBool:(1 == [self selectionCount:value])];
}

@end

@implementation JfhNotSingleSelectionTransformer

- (id)transformedValue:(id)value;
{
    if (nil == value) return [NSNumber numberWithBool:NO];
    else return [NSNumber numberWithBool:(1 != [self selectionCount:value])];
}

@end

@implementation JfhMultiSelectionTransformer

- (id)transformedValue:(id)value;
{
    if (nil == value) return [NSNumber numberWithBool:NO];
    else return [NSNumber numberWithBool:(1 < [self selectionCount:value])];
}

@end
