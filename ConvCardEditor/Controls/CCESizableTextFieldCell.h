//
//  CCESizableTextFieldCell.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/24/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum ETextControlSizerHandle {
    kLeft = 0,
    kRight,
    kTop,
    kBottom,
    
    kTopLeft,
    kTopRight,
    kBottomLeft,
    kBottomRight,
    
    kFirst = kLeft,
    kSimpleHandleCount = kBottom + 1,
    kDoubleHandleCount = kBottomRight + 1
    };

@interface CCESizableTextFieldCell : NSTextFieldCell {
    @protected
    NSRect rect[kDoubleHandleCount];
}

@property BOOL useDoubleHandles;
@property (nonatomic) NSFont *font;
@property CGFloat lineHeight;
@property NSUInteger lineCount;
@property NSColor *frameColor;

    // Returns the whole number of lines for the given height in points.
    // Amount will be rounded to nearest.
- (NSUInteger)linesForHeight:(CGFloat)height;

+ (void)setDefaultFont:(NSFont *)font;
+ (NSUInteger)linesForHeight:(CGFloat)height;

@end
