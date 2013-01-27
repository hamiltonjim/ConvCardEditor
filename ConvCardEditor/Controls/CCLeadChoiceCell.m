//
//  CCLeadChoiceCell.m
//  CCardX
//
//  Created by Jim Hamilton on 8/28/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCLeadChoiceCell.m,v 1.2 2010/12/21 05:13:27 jimh Exp $

#import "CCLeadChoiceCell.h"
#import "AppDelegate.h"
#import "CommonStrings.h"

static AppDelegate *appDel() {
    static AppDelegate *del = nil;
    if (nil == del)
        del = (AppDelegate *)[NSApp delegate];
    return del;
}

static double strokeWidth;

static NSColor *circleColor = nil;

@implementation CCLeadChoiceCell

@synthesize debugMode;

static NSColor *showColor;
static NSColor *selectedColor;

+ (void)initialize
{
    if (self != [CCLeadChoiceCell class]) {
        return;
    }
    
    showColor = [NSColor colorWithCalibratedRed:UNSELECTED_COLOR_R
                                          green:UNSELECTED_COLOR_G
                                           blue:UNSELECTED_COLOR_B
                                          alpha:UNSELECTED_COLOR_A];
    selectedColor = [NSColor colorWithCalibratedRed:SELECTED_COLOR_R
                                              green:SELECTED_COLOR_G
                                               blue:SELECTED_COLOR_B
                                              alpha:SELECTED_COLOR_A];
    
    strokeWidth = [[NSUserDefaults standardUserDefaults]
                   doubleForKey:ccLeadCircleStrokeWidth];
    [self setCircleColor:[NSUnarchiver unarchiveObjectWithData:
                          [[NSUserDefaults standardUserDefaults] valueForKey:ccLeadCircleColorKey]]];
}

+ (void) setStrokeWidth:(double)newWidth {
    strokeWidth = newWidth;
}

+ (void) setCircleColor:(NSColor *)newColor {
    circleColor = [newColor copy];
}

- (void) initObservations {
    [appDel() addObserver:self 
               forKeyPath:ccLeadCircleStrokeWidth
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    [appDel() addObserver:self 
               forKeyPath:ccLeadCircleColorKey
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    
}

- (id)initTextCell:(NSString *)aString {
    if ((self = [super initTextCell:aString]) != nil) {
        [self initObservations];
    }
    
    return self;
}

- (id)initImageCell:(NSImage *)image {
    if ((self = [super initImageCell:image]) != nil) {
        [self initObservations];
    }
    
    return self;
}

- (void) dealloc {
    [appDel() removeObserver:self forKeyPath:ccLeadCircleStrokeWidth];
    [appDel() removeObserver:self forKeyPath:ccLeadCircleColorKey];
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if (NSOnState == [self state]) {
        NSBezierPath *rpath = [NSBezierPath bezierPathWithOvalInRect:cellFrame];
        if (nil != circleColor)
            [circleColor set];
        
        [rpath setLineWidth:strokeWidth];
        [rpath stroke];
    } 
    
    if ([CCDebuggableControlEnable enabled] || debugMode) {
        NSColor *dColor;
        switch (debugMode) {
            case kOff:
                return;
                
            case kShowUnselected:
                dColor = showColor;
                break;
                
            case kShowSelected:
                dColor = selectedColor;
                break;
        }
        NSBezierPath *dpath = [NSBezierPath bezierPathWithOvalInRect:cellFrame];
        [dColor set];
        [dpath fill];
    }
}

    // instances observe
- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    if ([keyPath isEqualToString:ccLeadCircleStrokeWidth] 
        || [keyPath isEqualToString:ccLeadCircleColorKey]) {
        [[self controlView] setNeedsDisplay:YES];
    }
}

@end
