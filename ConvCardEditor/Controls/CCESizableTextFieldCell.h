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

@interface CCESizableTextFieldCell : NSCell {
    @protected
    NSRect _dragRect[kDoubleHandleCount];
}

@property BOOL useDoubleHandles;

@property NSArray *dragRectArray;
@property NSRect textRect;
@property NSRect borderRect;

@property (nonatomic) int debugMode;

@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;
@property (nonatomic) SEL doubleAction;

+ (NSPoint)insetSize;


@end
