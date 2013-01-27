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

@class CCESingleCheckModel;
@class CCELocation;

@interface CCCheckbox : NSButton <CCDebuggableControl>

@property id <CCctrlParent> parent;
@property (nonatomic) CCESingleCheckModel *modelledControl;
@property (nonatomic) CCELocation *modelLocation;
@property (nonatomic) NSColor *color;

@property NSRect frameRect;

+ (id)checkboxWithCheckModel:(CCESingleCheckModel *)model;

- (id)initWithModel:(CCESingleCheckModel *)model;

- (id) initWithFrame:(NSRect)frameR color:(NSColor *)aColor;
- (id) initWithFrame:(NSRect)frameR colorKey:(NSString *)aColorKey;

- (void) setColorKey:(NSString *)key;

@end
