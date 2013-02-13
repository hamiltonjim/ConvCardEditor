//
//  NSControl+CCESetColorCode.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/2/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSControl (CCESetColorCode)

- (void)setColorCode:(NSInteger)code;
- (void)setModelColor:(NSColor *)color;

@end
