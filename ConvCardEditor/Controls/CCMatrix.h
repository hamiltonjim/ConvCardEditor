//
//  CCMatrix.h
//  CCardX
//
//  Created by Jim Hamilton on 8/29/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCMatrix.h,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCctrlParent.h"
#import "CCDebuggableControl.h"

enum ENounCase {
    kNominative = 1,
    kObjective,
    kPossessive
};

enum EIndexingError {
    kNoError = 0,
    kIndexOutOfRange = 1,
    kOldIndexOutOfRange = 2,

    kUnknownError = 100
};

@class CCEMultiCheckModel;

    // An aggregate control that behaves like a radio group
@interface CCMatrix : NSControl <CCctrlParent, CCDebuggableControl>  

@property (nonatomic) NSMutableArray *controls;
@property BOOL allowsEmptySelection;
@property BOOL allowsMultiSelection;

@property (readonly, weak) NSControl *selected;
@property NSNumber *value;

@property NSString *name;

@property (readonly) BOOL isReindexing;

@property (weak, nonatomic) CCEModelledControl *modelledControl;

    // factory can return various subclasses
+ (CCMatrix *)matrixFromModel:(CCEMultiCheckModel *)model;
+ (CCMatrix *)matrixFromModel:(CCEMultiCheckModel *)model insideRect:(NSRect)rect;

- (id) initWithFrame:(NSRect)bounds name:(NSString *)name;

- (void)choose;
- (void)updateBoundObjects;

- (BOOL)deleteChild:(id <CCDebuggableControl>)child;

    // to change the index of a child control (others re-index to comply)
- (NSInteger)reindexFrom:(NSUInteger)fromIndex
                      to:(NSUInteger)toIndex
                   error:(NSError *__autoreleasing *)error;

- (NSControl <CCDebuggableControl> *)childWith1Index:(NSUInteger)index;

- (NSUInteger)tagChild:(NSControl <CCDebuggableControl> *)child;

    // if a child is to be deleted, keep the remaining indices contiguous;
    // remove the child at the given index and return it.
- (NSControl <CCDebuggableControl> *)removeChild:(NSUInteger)index;
    // esp. when a child is deleted, get the new "suggested" child index
- (NSUInteger)currentIndex;

- (void)addChildControl:(id <CCDebuggableControl>)child;

- (void)placeChildControlsInRects:(NSArray *)rects;

    // The following methods must be defined in subclasses
- (NSControl <CCDebuggableControl> *)createChildInRect:(NSRect)theRect;

- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color;
- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode;
- (void)placeChildInRect:(NSRect)rect withColorKey:(NSString *)colorKey;

- (void)placeChildWithLocation:(NSManagedObject *)location withColor:(NSColor *)color;
- (void)placeChildWithLocation:(NSManagedObject *)location withColorCode:(NSInteger)colorCode;
- (void)placeChildWithLocation:(NSManagedObject *)location withColorKey:(NSString *)colorKey;

    // the name of the shape, either as possessive case ("shape's") or nominative/objective ("shape")
- (NSString *)shapeName:(NSInteger)nounCase;

@end
