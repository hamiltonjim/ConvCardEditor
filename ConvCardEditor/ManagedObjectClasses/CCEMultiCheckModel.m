//
//  CCEMultiCheck.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/18/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEMultiCheckModel.h"
#import "CommonStrings.h"
#import "CCELocation.h"
#import "CCDebuggableControl.h"
#import "CCELocationController.h"
#import "CCMatrix.h"

static NSString *locations = @"locations";

@interface CCEMultiCheckModel ()

@property (nonatomic, readwrite) NSNumber *numParts;

- (void)reindexLocationAt:(NSUInteger)oldIndex to:(NSUInteger)newIndex;

@end

@implementation CCEMultiCheckModel

@dynamic locations;
@dynamic shape;


- (void)setLocation:(CCELocation *)location
{
    NSMutableSet *locs = [self mutableSetValueForKey:locations];
    if (locs != nil) {
        NSUInteger index = location.index.integerValue;
        CCELocation *existing = [self locationWithIndex:index];
        if (existing) {
            [locs removeObject:existing];
            
        }
        [locs addObject:location];
        self.numParts = [NSNumber numberWithInteger:locs.count];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:ccModelLocation]) {
        return nil;
    }
    
    return [super valueForUndefinedKey:key];
}

- (id)location
{
    return [self locationWithIndex:1];
}

- (CCELocation *)locationWithIndex:(NSInteger)index
{
    NSSet *locSet = [self.locations objectsPassingTest:^BOOL(CCELocation *obj, BOOL *stop) {
        BOOL result = [obj.index integerValue] == index;
        if (result) {
            *stop = YES;
        }
        return result;
    }];
    
        // result set will have either zero entries, and return nil;
        //      or a single entry, and return it.
    return [locSet anyObject];
}

- (void)removeLocationWithIndex:(NSUInteger)index
{
    NSMutableSet *locSet = [self mutableSetValueForKey:locations];
    CCELocation *removedLoc = [self locationWithIndex:index];
    [locSet removeObject:removedLoc];
    
    NSUInteger count = [locSet count];
    for (NSUInteger idx = index; idx <= count; ++idx) {
        [self reindexLocationAt:idx + 1 to:idx];
    }
    
        // new count
    self.numParts = [NSNumber numberWithInteger:locSet.count];
}

- (void)reindexLocationAt:(NSUInteger)oldIndex to:(NSUInteger)newIndex
{
    CCELocation *loc = [self locationWithIndex:oldIndex];
    [loc setIndex:[NSNumber numberWithInteger:newIndex]];
}

@end
