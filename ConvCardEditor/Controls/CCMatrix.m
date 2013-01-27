//
//  CCMatrix.m
//  CCardX
//
//  Created by Jim Hamilton on 8/29/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCMatrix.m,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import <Foundation/NSObjCRuntime.h>
#import "CCMatrix.h"
#import "AppDelegate.h"

static NSString * CCMatrixValueStr = @"value";

@implementation CCMatrix

@synthesize controls;
@synthesize allowsEmptySelection;
@synthesize allowsMultiSelection;

@synthesize selected;
@synthesize value;

@synthesize name;
@synthesize modelledControl;

static NSInteger 
mask2index(NSUInteger mask) {
    NSInteger index = -1;
    
    while (mask) {
        mask >>= 1;
        ++index;
    }
    return index;
}

+ (void) initialize {
    if (self == [CCMatrix class])
        [self exposeBinding:CCMatrixValueStr];
}

+ (id) cellClass {
    return nil;
}

- (id) initWithFrame:(NSRect)bounds name:(NSString *)matrixName {
    if ((self = [super initWithFrame:bounds])) {
        selected = nil;
    }
    name = matrixName;
    return self;
}

- (void) choose {
    NSInteger ival = -1;
    
    if (value) ival = [value integerValue];
    
    for (NSControl *ctrl in controls) {
        [ctrl setIntegerValue:0];
    }
    
    [self updateBoundObjects];
    
    if (allowsMultiSelection) {
        if (ival < 0) return;
        
        NSInteger maxIndex = [controls count] - 1;
        while (ival) {
                // get right-most 1 bit
                // property of 2's complement integers: 
            NSUInteger rightmost = ival & -ival;
                // mask -> index
            NSInteger index = mask2index(rightmost);
            if (index > maxIndex) break;
            
            NSControl *it = (NSControl *)[controls objectAtIndex:index];
            [it setIntegerValue:1];
            
            ival -= rightmost;
        }
        
        selected = nil;
    } else {
        if (ival < 0 || ival >= [controls count]) return;
        
        NSControl *it = (NSControl *)[controls objectAtIndex:ival];
        selected = it;
        [it setIntegerValue:1];
    }
}

- (void) updateBoundObjects {
    NSDictionary *bdict = [self infoForBinding:CCMatrixValueStr];
    if (bdict) {
        NSObject *obj = [bdict objectForKey:NSObservedObjectKey];
        NSString *path = [bdict objectForKey:NSObservedKeyPathKey];
        
        if (obj)
            [obj setValue:value forKeyPath:path];
    }
}

- (void)setValue:(NSNumber *)aVal {
    value = [aVal copy];
    
    [self choose];
}
- (NSNumber *)value {
    return [value copy];
}

-(BOOL) validateValue:(id *)ioValue error:(NSError **)outError {
    if ([*ioValue respondsToSelector:@selector(integerValue)]) {
        NSInteger val = [*ioValue integerValue];
        if (val >= 0 && val < [controls count])
            return YES;
    } else if (nil == *ioValue) {
        return YES;
    }
    
    
    NSString *estr = @"invalid value";
    NSDictionary *dct = [NSDictionary dictionaryWithObject:estr forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"VALUES" code:-1 userInfo:dct];
    if (outError)
        *outError = error;
    return NO;
}

- (void)notify:(NSControl *)sender {
    if (allowsMultiSelection) {
        NSInteger ival = 0;
        NSInteger mask = 1;
        for (NSControl *ctrl in controls) {
            if ([ctrl integerValue])
                ival |= mask;
            mask <<= 1;
        }
        
        selected = nil;
        self.value = [NSNumber numberWithInteger:ival];
    } else {
        if ([sender integerValue]) {
            if (selected) {
                [selected setIntegerValue:0];
            }
            
            selected = sender;
            self.value = [NSNumber numberWithInteger:[selected tag]];
        } else if (allowsEmptySelection && selected == sender) {
            selected = nil;
            self.value = nil;
        }
    }
}

    // pass bind to child controls, if it is a "hidden" binding
- (void) bind:(NSString *)binding toObject:(id)observable
  withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    if ([binding compare:@"hidden" options:0 range:NSMakeRange(0, 6)] == NSOrderedSame)
         for (NSControl *ctrl in controls) {
             [ctrl bind:binding toObject:observable withKeyPath:keyPath options:options];
         }
    else {
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    }

}

- (void) setShortValue:(short)aShort {
    [self setValue:[NSNumber numberWithShort:aShort]];
}
- (void) setIntValue:(int)aVal {
    [self setValue:[NSNumber numberWithInt:aVal]];
}
- (void) setIntegerValue:(NSInteger)anInteger {
    [self setValue:[NSNumber numberWithInteger:anInteger]];
}
- (void) setFloatValue:(float)aFloat {
    [self setValue:[NSNumber numberWithFloat:aFloat]];
}
- (void) setDoubleValue:(double)aDouble {
    [self setValue:[NSNumber numberWithDouble:aDouble]];
}

- (short) shortValue {
    return [value shortValue];
}
- (int) intValue {
    return [value intValue];
}
- (NSInteger) integerValue {
    return [value integerValue];
}
- (float) floatValue {
    return [value floatValue];
}
- (double) doubleValue {
    return [value doubleValue];
}

- (void)deleteChild:(id<CCDebuggableControl>)child
{
    NSLog(@"CCMatrix deleteChild: not implemented");
}

- (void)subclassResponsibility:(SEL)sel
{
    [NSException raise:@"SubclassResponsibility"
                format:@"Method %@ must be defined in %@",
     NSStringFromSelector(sel), NSStringFromClass([self class])];

}

- (void)addChildControl:(id)child
{
    [self subclassResponsibility:@selector(addChildControl:)];
}

- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color
{
    [self subclassResponsibility:@selector(placeChildInRect:withColor:)];

}

- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode
{
    [self subclassResponsibility:@selector(placeChildInRect:withColorCode:)];
}

- (void)placeChildInRect:(NSRect)rect withColorKey:(NSString *)colorKey
{
    [self subclassResponsibility:@selector(placeChildInRect:withColorKey:)];
}

- (void)placeChildWithLocation:(NSManagedObject *)location withColor:(NSColor *)color
{
    [self subclassResponsibility:@selector(placeChildWithLocation:withColor:)];
}

- (void)placeChildWithLocation:(NSManagedObject *)location withColorCode:(NSInteger)colorCode
{
    [self subclassResponsibility:@selector(placeChildWithLocation:withColorCode:)];
}

- (void)placeChildWithLocation:(NSManagedObject *)location withColorKey:(NSString *)colorKey
{
    [self subclassResponsibility:@selector(placeChildWithLocation:withColorKey:)];
}

- (void) setDebugMode:(int)val {
    for (NSControl <CCDebuggableControl> *ctrl in controls)
        [ctrl setDebugMode:val];
}

@end
