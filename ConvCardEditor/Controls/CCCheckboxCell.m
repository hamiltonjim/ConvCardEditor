//
//  CCCheckboxCell.m
//  CCardX
//
//  Created by Jim Hamilton on 8/19/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCCheckboxCell.m,v 1.4 2010/12/21 05:13:27 jimh Exp $

#import "CCCheckboxCell.h"
#import "AppDelegate.h"

static NSInteger checkboxStyle;

static AppDelegate *appDel() {
    static AppDelegate *del = nil;
    if (nil == del)
        del = (AppDelegate *)[NSApp delegate];
    return del;
}

static BOOL sDebugNames = NO;

@interface CCCheckboxCell(private_additions)

- (void) watchColor:(NSString *)aColorKey;
- (void) unwatchColor;

@end

@implementation CCCheckboxCell(private_additions)

- (void) watchColor:(NSString *)aColorKey {
    [self unwatchColor];
    if (aColorKey) {
        colorKey = aColorKey;
        [appDel() addObserver:self
                   forKeyPath:colorKey 
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:nil];
        [self setColor:[appDel() valueForKey:colorKey]];
    }
}
- (void) unwatchColor {
    if (colorKey) {
        [appDel() removeObserver:self forKeyPath:colorKey];
        
        colorKey = nil;
    }
}

    // called when a checkbox is drawn with ON state (first time checked)
- (void) observeCheckboxStyle {
    if (observingSet)
        return;
    
    [appDel() addObserver:self 
               forKeyPath:ccCheckboxDrawStyle
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    observingSet = YES;    
}

@end

@implementation CCCheckboxCell

@synthesize color;
@synthesize colorKey;
@synthesize debugMode;
@synthesize dName;
@synthesize forceMode;

+ (void) setCheckboxStyle:(NSInteger)newStyle {
    checkboxStyle = newStyle;
}

+ (void) setDebugNames:(BOOL)mode {
    sDebugNames = mode;
}

+ (void) initialize {
    if (self == [CCCheckboxCell class]) {
        [self setCheckboxStyle:[[NSUserDefaults standardUserDefaults]
                                integerForKey:ccCheckboxDrawStyle]];
    }
}

- (void) dealloc {
    [self unwatchColor];
    
    [appDel() removeObserver:self forKeyPath:ccCheckboxDrawStyle];
}

- (id)copyWithZone:(NSZone *)zone {
    CCCheckboxCell *cpy = [[CCCheckboxCell allocWithZone:zone] initCCCheckboxCellWithColor:color name:dName];
    [cpy setColorKey:colorKey];
    return cpy;
}

- (id) initCCCheckboxCellWithColor:(NSColor *)col {
    return [self initCCCheckboxCellWithColor:col name:nil];
}
- (id) initCCCheckboxCellWithColor:(NSColor *)col name:(NSString *)aName {
    if ((self = [self initTextCell:aName])) {
        self.color = col;
        self.debugMode = NO;
        self.dName = aName;
        
        [self setButtonType:NSOnOffButton];
        [self observeCheckboxStyle];
    }
    return self;
}

- (void) setColorKey:(NSString *)aKey {
    [self watchColor:aKey];
}
- (NSString *)colorKey {
    return colorKey;
}

- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if (NSOnState == [self state]){
        [self observeCheckboxStyle];
        NSBezierPath *rpath;
        double width = cellFrame.size.width;
        double height = cellFrame.size.height;
        BOOL fill = NO;
        [color set];
        
        NSInteger style;
        if (forceMode)
            style = [forceMode integerValue];
        else
            style = checkboxStyle;
        
        switch (style) {
            case CCCheckboxStyleSolid:
            default:
                rpath = [NSBezierPath bezierPathWithRect:cellFrame];
                fill = YES;
                break;
                
            case CCCheckboxStyleCheck:
                rpath = [NSBezierPath bezierPath];
                [rpath moveToPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y)];
                [rpath relativeMoveToPoint:NSMakePoint(0.0, height / 2)];
                
                [rpath setLineWidth:width / 6];
                [rpath setLineJoinStyle:NSMiterLineJoinStyle];
                
                [rpath relativeLineToPoint:NSMakePoint(width / 2 - 1, height / 2 - 1)];
                [rpath relativeLineToPoint:NSMakePoint(width / 2, -height)];
                break;
                
            case CCCheckboxStyleCross:
                rpath = [NSBezierPath bezierPath];
                [rpath setLineWidth:width / 6];
                [rpath setLineJoinStyle:NSMiterLineJoinStyle];
                
                [rpath moveToPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y)];
                [rpath relativeLineToPoint:NSMakePoint(width, height)];
                
                [rpath relativeMoveToPoint:NSMakePoint(-width, 0.0)];
                [rpath relativeLineToPoint:NSMakePoint(width, -height)];
                break;
        }
        if (fill) {
            [rpath fill];
        } else {
            [rpath stroke];
        }
    }
    
    if ([CCDebuggableControlEnable enabled] || debugMode) {
        NSColor *dcolor = [NSColor colorWithCalibratedRed:1.0 green:0.5 blue:0.0 alpha:0.5];
        NSBezierPath *dpath = [NSBezierPath bezierPathWithRect:cellFrame];
        [dcolor set];
        [dpath fill];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    if (object != appDel()) 
        return;
    
    if ([keyPath isEqualToString:colorKey]) {
        [self setColor:[appDel() valueForKey:colorKey]];
        if (sDebugNames && dName)
            NSLog(@"Set cell named %@ to color %@", dName, colorKey);
    } else if ([keyPath isEqualToString:ccCheckboxDrawStyle]) {
        [[self controlView] setNeedsDisplay:YES];
    }

}

@end
