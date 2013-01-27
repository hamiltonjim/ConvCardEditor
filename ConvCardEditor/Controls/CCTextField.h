//
//  CCTextField.h
//  CCardX
//
//  Created by Jim Hamilton on 8/23/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCTextField.h,v 1.3 2010/11/01 03:25:21 jimh Exp $


#import <Cocoa/Cocoa.h>
#import "CCDebuggableControl.h"

@class AppDelegate;
@class CCETextModel;
@class CCELocation;

@interface CCTextField : NSTextField <NSTextFieldDelegate, CCDebuggableControl>

@property (nonatomic) CCETextModel *modelledControl;
@property (nonatomic) CCELocation *modelLocation;
@property BOOL allOrNothing;  // if YES, refers to selection (used for font prefs panel)

+ (NSNumberFormatter*) numFormatter;
+ (AppDelegate *) appDel;

+ (void) readMagic;

+ (CCTextField *)textFieldFromModel:(CCETextModel*)model;

- (id) initWithFrame:(NSRect)frameRect font:(NSString *)aFont;
- (id) initWithFrame:(NSRect)frameRect font:(NSString *)aFont color:(NSColor *)aColor;
- (id) initWithFrame:(NSRect)frameRect font:(NSString *)aFont isNumber:(BOOL)isNum;
- (id) initWithFrame:(NSRect)frameRect
                font:(NSString *)aFont
               color:(NSColor *)aColor
            isNumber:(BOOL)isNum;

- (id) initWithFrame:(NSRect)frameRect font:(NSString *)aFont colorKey:(NSString *)aColorKey;
- (id) initWithFrame:(NSRect)frameRect
                font:(NSString *)aFont
            colorKey:(NSString *)aColorKey
            isNumber:(BOOL)isNum;

    // instantiate from model record
- (id)initWithTextModel:(CCETextModel *)model;
- (id)initWithLocation:(CCELocation *)location;
- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum;
- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum color:(NSColor *)color;
- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum colorCode:(NSInteger)colorCode;

- (void) setColorByCode:(NSInteger)code;

- (void) suitSubstitution:(NSTextView *)editor;

@end
