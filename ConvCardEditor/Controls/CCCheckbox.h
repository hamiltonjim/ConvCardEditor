//
//  CCCheckbox.h
//  CCardX
//
//  Created by Jim Hamilton on 8/19/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCCheckbox.h,v 1.4 2010/12/21 05:13:27 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCCheckboxCell.h"
#import "CCctrlParent.h"
#import "CCDebuggableControl.h"

@interface CCCheckbox : NSButton <CCDebuggableControl> {
    NSRect frame;
    NSColor *color;
    NSObject <CCctrlParent> *parent;
    
    BOOL unscaled;
}

@property (retain) id <CCctrlParent> parent;

- (id) initWithFrameUnscaled:(NSRect)frameRect;

- (id) initWithFrame:(NSRect)frameRect color:(NSColor *)aColor;
- (id) initWithFrame:(NSRect)frameRect colorKey:(NSString *)aColorKey;

- (NSColor *) getColor;
- (void) setColor:(NSColor *) color;

- (void) setColorKey:(NSString *)key;

- (void) setDName:(NSString *)name;

@end
