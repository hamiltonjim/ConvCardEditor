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

    // An aggregate control that behaves like a radio group
@interface CCMatrix : NSControl <CCctrlParent, CCDebuggableControl>  

@property NSMutableArray *controls;
@property BOOL allowsEmptySelection;
@property BOOL allowsMultiSelection;

@property (readonly, weak) NSControl *selected;
@property (copy) NSNumber *value;

@property NSString *name;

@property CCEModelledControl *modelledControl;

- (id) initWithFrame:(NSRect)bounds name:(NSString *)name;

- (void) choose;
- (void) updateBoundObjects;

- (void)deleteChild:(id <CCDebuggableControl>)child;

    // The following methods must be defined in subclasses
- (void)addChildControl:(id <CCDebuggableControl>)child;

- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color;
- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode;
- (void)placeChildInRect:(NSRect)rect withColorKey:(NSString *)colorKey;

- (void)placeChildWithLocation:(NSManagedObject *)location withColor:(NSColor *)color;
- (void)placeChildWithLocation:(NSManagedObject *)location withColorCode:(NSInteger)colorCode;
- (void)placeChildWithLocation:(NSManagedObject *)location withColorKey:(NSString *)colorKey;

@end
