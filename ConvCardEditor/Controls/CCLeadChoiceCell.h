//
//  CCLeadChoiceCell.h
//  CCardX
//
//  Created by Jim Hamilton on 8/28/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCLeadChoiceCell.h,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCDebuggableControl.h"

@interface CCLeadChoiceCell : NSButtonCell <CCDebuggableControl>

@property (nonatomic) int debugMode;

+ (void) setStrokeWidth:(double)newWidth;
+ (void) setCircleColor:(NSColor *)newColor;

- (void) initObservations;

@end
