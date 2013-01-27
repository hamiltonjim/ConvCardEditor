//
//  CCESizableTextField.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/24/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCTextField.h"

/*
 Creates a rect with the two given points as opposite corners.
 It doesn't matter whether the corners are top-right and bottom-left
 or top-left and bottom-right, or which is which
 */
NSRect JFH_RectFromPoints(NSPoint p1, NSPoint p2);

@interface CCESizableTextField : CCTextField

@property (getter = isSelected) BOOL selected;

    // sizers

@end
