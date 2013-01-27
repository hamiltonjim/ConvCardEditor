//
//  CCELocation.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCELocation.h"
#import "AppDelegate.h"

#define ZERO 0.0
#define ONE 1.0

@interface CCELocation  ()

- (void)setColor:(NSColor *)color clearColorCode:(BOOL)clear;

@end

@implementation CCELocation

@dynamic colorAlpha;
@dynamic colorRed;
@dynamic colorGreen;
@dynamic colorBlue;

@dynamic colorCode;
@synthesize color;

@dynamic index;

@dynamic width;
@dynamic height;
@dynamic locX;
@dynamic locY;

@dynamic checkControl;
@dynamic multiCheckControl;
@dynamic textControl;

- (void)awakeFromFetch
{
    NSNumber *code = self.colorCode;
    if (code != nil) {
        AppDelegate *del = [NSApp delegate];
        [self setColor:[del colorForCode:[code integerValue]] clearColorCode:NO];
    } else {
        CGFloat red = self.colorRed ? [self.colorRed doubleValue] : ZERO;
        CGFloat green = self.colorGreen ? [self.colorGreen doubleValue] : ZERO;
        CGFloat blue = self.colorBlue ? [self.colorBlue doubleValue] : ZERO;
        CGFloat alpha = self.colorAlpha ? [self.colorAlpha doubleValue] : ONE;
        self.color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
    }
}

- (void)setColorCode:(NSNumber *)code
{
    NSString *key = @"colorCode";
    [self willChangeValueForKey:key];

        // set the color values directly
    NSColor *aColor = nil;
    if (code != nil) {
        aColor = [[NSApp delegate] colorForCode:[code integerValue]];
        if (aColor != nil) {
            [self setColor:aColor clearColorCode:NO];
        }
    }

        // now, set the code correctly
    [self setPrimitiveValue:code forKey:key];
    [self didChangeValueForKey:key];
    
}

- (void)setColor:(NSColor *)aColor
{
        // change color code
    [self setColor:color clearColorCode:YES];
}

- (void)setColor:(NSColor *)aColor clearColorCode:(BOOL)clear
{
    NSString *key = @"colorCode";
    [self willChangeValueForKey:key];
    color = [aColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    [self didChangeValueForKey:key];
    
    self.colorRed = [NSNumber numberWithDouble:[color redComponent]];
    self.colorGreen = [NSNumber numberWithDouble:[color greenComponent]];
    self.colorBlue = [NSNumber numberWithDouble:[color blueComponent]];
    self.colorAlpha = [NSNumber numberWithDouble:[color alphaComponent]];

    if (clear) {
        key = @"colorCode";
        [self willChangeValueForKey:key];
        [self setPrimitiveValue:nil forKey:key];
        [self didChangeValueForKey:key];
    }
}

@end
