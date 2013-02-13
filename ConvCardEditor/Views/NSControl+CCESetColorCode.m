//
//  NSControl+CCESetColorCode.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/2/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "NSControl+CCESetColorCode.h"
#import "AppDelegate.h"

@implementation NSControl (CCESetColorCode)

- (void)setColorCode:(NSInteger)code
{
    if ([self respondsToSelector:@selector(setColorKey:)]) {
        NSString *key = [(AppDelegate *)[NSApp delegate] colorKeyForCode:code];
        [self performSelector:@selector(setColorKey:) withObject:key];
    }
}

- (void)setModelColor:(NSColor *)color
{
    if ([self respondsToSelector:@selector(setColor:)]) {
        [self performSelector:@selector(setColor:) withObject:color];
    }
}

@end
