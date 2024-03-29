//
//  CCCheckboxCell.m
//  CCardX
//
//  Created by Jim Hamilton on 8/19/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCCheckboxCell.m,v 1.4 2010/12/21 05:13:27 jimh Exp $

#import "CCCheckboxCell.h"
#import "CCEConstants.h"
#import "AppDelegate.h"
#import "NSUserDefaults+CCEColorOps.h"

static AppDelegate *appDel() {
    static AppDelegate *del = nil;
    if (nil == del)
        del = (AppDelegate *)[NSApp delegate];
    return del;
}

static BOOL observingSet = NO;

@interface CCCheckboxCell()

- (void) watchColor:(NSString *)aColorKey;
- (void) unwatchColor;

@end

@implementation CCCheckboxCell

@synthesize color;
@synthesize colorKey;
@synthesize debugMode;
@synthesize forceMode;

static NSInteger checkboxStyle;

static NSColor *showColor;
static NSColor *selectedColor;
static NSColor *selectedOtherColor;

+ (void)initialize
{
    if (self != [CCCheckboxCell class]) {
        return;
    }
    
    showColor = [CCEConstants unselectedColor];
    selectedColor = [CCEConstants selectedColor];
    selectedOtherColor = [CCEConstants selectedOtherColor];
    
    [self setCheckboxStyle:[[NSUserDefaults standardUserDefaults]
                            integerForKey:ccCheckboxDrawStyle]];
}

+ (void) setCheckboxStyle:(NSInteger)newStyle {
    checkboxStyle = newStyle;
}

- (id)monitorModel:(CCEModelledControl *)model
{
    [NSException raise:@"NotImplementedInCell"
                format:@"monitorModel should not be implemented in cell class %@", [self class]];
    return nil;
}

- (void) dealloc {
    [self unwatchColor];
}

- (id)copyWithZone:(NSZone *)zone {
    CCCheckboxCell *cpy = [[CCCheckboxCell allocWithZone:zone] initCCCheckboxCellWithColor:color];
    [cpy setColorKey:colorKey];
    return cpy;
}

- (void)setDebugMode:(int)mode
{
    debugMode = mode;
    [[self controlView] setNeedsDisplay:YES];
}

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
    
    [appDel() watchCheckboxStyle];
    observingSet = YES;
}

- (id) initCCCheckboxCellWithColor:(NSColor *)col {
    if ((self = [self initTextCell:nil])) {
        self.color = col;
        self.debugMode = kOff;
        
        [self setButtonType:NSOnOffButton];
        observingSet = NO;
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
    if (forceMode || NSOnState == [self state]){
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
    
    if (!forceMode && [CCDebuggableControlEnable enabled]) {
        NSColor *dColor;
        switch (debugMode & ~kShowHighlight) {
            case kOff:
                return;
                
            case kShowUnselected:
                dColor = showColor;
                break;
                
            case kShowSelected:
                dColor = selectedColor;
                break;
                
            case kShowSelectedOther:
                dColor = selectedOtherColor;
                break;
        }
        NSBezierPath *dpath = [NSBezierPath bezierPathWithRect:cellFrame];
        [dColor set];
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
        [[self controlView] setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:ccCheckboxDrawStyle]) {
        [[self controlView] setNeedsDisplay:YES];
    }

}

@end
