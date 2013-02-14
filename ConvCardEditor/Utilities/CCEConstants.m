//
//  CCEConstants.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/7/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEConstants.h"
#import "CommonStrings.h"

static NSColor *unselectedColor;
static NSColor *selectedColor;
static NSColor *selectedOtherColor;

@implementation CCEConstants

+ (NSColor *)unselectedColor
{
    if (unselectedColor == nil)
        @synchronized(self) {
            unselectedColor = [NSColor colorWithCalibratedRed:UNSELECTED_COLOR_R
                                                        green:UNSELECTED_COLOR_G
                                                         blue:UNSELECTED_COLOR_B
                                                        alpha:UNSELECTED_COLOR_A];
        }
    return unselectedColor;
}

+ (NSColor *)selectedColor
{
    if (selectedColor == nil)
        @synchronized(self){
            selectedColor = [NSColor colorWithCalibratedRed:SELECTED_COLOR_R
                                                      green:SELECTED_COLOR_G
                                                       blue:SELECTED_COLOR_B
                                                      alpha:SELECTED_COLOR_A];
        }
    return selectedColor;
}

+ (NSColor *)selectedOtherColor
{
    if (selectedOtherColor == nil)
        @synchronized(self){
            selectedOtherColor = [NSColor colorWithCalibratedRed:SELECTED_OTHER_CL_R
                                                           green:SELECTED_OTHER_CL_G
                                                            blue:SELECTED_OTHER_CL_B
                                                           alpha:SELECTED_OTHER_CL_A];
        }
    return selectedOtherColor;
}

@end
