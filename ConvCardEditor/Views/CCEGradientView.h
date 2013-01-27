//
//  CCEGradientView.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/26/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCEGradientView : NSView

@property (nonatomic) NSColor *startingColor;
@property (nonatomic) NSColor *endingColor;
@property (nonatomic) CGFloat angle;

@end
