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
    
    int debugMode;
    
    NSNumber *forceMode;
}

@property NSColor *color;
@property NSString *colorKey;

@property (nonatomic) int debugMode;

@property NSNumber *forceMode;

- (id) initCCCheckboxCellWithColor:(NSColor *)col;

+ (void) setCheckboxStyle:(NSInteger)newStyle;

@end
