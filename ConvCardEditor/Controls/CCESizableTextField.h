//
//  CCESizableTextField.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/24/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCTextField.h"
#import "CCDebuggableControl.h"
#import "CCESizableTextFieldCell.h"

@class CCETextModel;

/*
 Creates a rect with the two given points as opposite corners.
 It doesn't matter whether the corners are top-right and bottom-left
 or top-left and bottom-right, or which is which
 */
NSRect JFH_RectFromPoints(NSPoint p1, NSPoint p2);

@interface CCESizableTextField : NSControl <CCDebuggableControl>

@property (getter = isSelected) BOOL selected;
@property CCTextField *insideTextField;

    // sizers
@property NSArray *sizerHandles;

@property BOOL useDoubleHandles;
@property (nonatomic) NSFont *font;
@property (readonly) CGFloat lineHeight;
@property (readonly) NSUInteger lineCount;
@property NSColor *frameColor;

@property (readonly) CGFloat scale;

@property (getter = isNumberField) BOOL numberField;
//@property (readonly) NSUInteger clickCount;

    // Returns the whole number of lines for the given height in points.
    // Amount will be rounded to nearest.
- (NSUInteger)linesForHeight:(CGFloat)height;

+ (void)setDefaultFont:(NSFont *)font;
+ (NSUInteger)linesForHeight:(CGFloat)height;

+ (CCESizableTextField *)textFieldFromModel:(CCETextModel *)model;

    // instantiate from model record
- (id)initWithTextModel:(CCETextModel *)model;
- (id)initWithLocation:(CCELocation *)location;
- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum;
- (id)initWithLocation:(CCELocation *)location
              isNumber:(BOOL)isNum
                 color:(NSColor *)color;
- (id)initWithLocation:(CCELocation *)location
              isNumber:(BOOL)isNum
             colorCode:(NSInteger)colorCode;
- (id)initWithLocation:(CCELocation *)location
              isNumber:(BOOL)isNum
              colorKey:(NSString *)colorKey;

    // Designated initializer; all above eventually call this one, and it's the only one
    // that would need to be overridden.
- (id)initWithFrame:(NSRect)frRect
           isNumber:(BOOL)isNum
          colorName:(NSString *)colorName
              color:(NSColor *)color
               font:(NSString *)fontName
           fontSize:(CGFloat)fontSize;

- (void)setColor:(NSColor *)aColor;
- (NSColor *)color;

- (void)setColorKey:(NSString *)aColorKey;
- (NSString *)colorKey;

- (BOOL)isPointInsideMe:(NSPoint)aPoint;

+ (NSInteger)count;

@end
