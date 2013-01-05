//
//  CCCheckboxCell.h
//  CCardX
//
//  Created by Jim Hamilton on 8/19/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCCheckboxCell.h,v 1.4 2010/12/21 05:13:27 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCDebuggableControl.h"
#import "CommonStrings.h"

enum CCCheckboxStyle {
    CCCheckboxStyleSolid,
    CCCheckboxStyleCheck,
    CCCheckboxStyleCross
};

@interface CCCheckboxCell : NSButtonCell <CCDebuggableControl> {
    NSColor *color;
    NSString *colorKey;
    
    BOOL observingSet;
    
    BOOL debugMode;
    NSString *dName;
    
    NSNumber *forceMode;
}

@property (copy) NSColor *color;
@property (retain) NSString *colorKey;

@property BOOL debugMode;
@property (retain) NSString *dName;

@property (retain) NSNumber *forceMode;

- (id) initCCCheckboxCellWithColor:(NSColor *)col;
- (id) initCCCheckboxCellWithColor:(NSColor *)col name:(NSString *)name;

+ (void) setCheckboxStyle:(NSInteger)newStyle;
+ (void) setDebugNames:(BOOL)mode;

@end
