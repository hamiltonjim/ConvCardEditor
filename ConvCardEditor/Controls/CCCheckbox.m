//
//  CCCheckbox.m
//  CCardX
//
//  Created by Jim Hamilton on 8/19/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCCheckbox.m,v 1.4 2010/12/21 05:13:27 jimh Exp $

#import "CCCheckbox.h"
#import "CCEModelledControl.h"
#import "CCESingleCheckModel.h"
#import "CCELocation.h"
#import "NSView+ScaleUtilities.h"
#import "AppDelegate.h"

@implementation CCCheckbox

@synthesize frameRect;
@synthesize parent;
@synthesize modelledControl;
@synthesize modelLocation;
@synthesize color;

- (int) debugMode {
    return [[self cell] debugMode];
}
- (void) setDebugMode:(int) newDebugMode {
    [[self cell] setDebugMode:newDebugMode];
}

+ (CCCheckbox *)checkboxWithCheckModel:(CCESingleCheckModel *)model
{
    return [[self alloc] initWithModel:model];
}

- (CCESingleCheckModel *)modelledControl
{
    return modelledControl;
}
- (void)setModelledControl:(CCESingleCheckModel *)model
{
    modelledControl = model;
    CCELocation *location = [modelledControl valueForKey:ccModelLocation];
    if (location != nil) {
        self.modelLocation = location;
    }
}

- (void)setModelLocation:(CCELocation *)location
{
        // stop observing old location, if any
    if (modelLocation != nil) {
        [[CommonStrings dimensionKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            [modelLocation removeObserver:self forKeyPath:@"key"];
        }];
    }
    
    modelLocation = location;
    
    [[CommonStrings dimensionKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        [modelLocation addObserver:self
                        forKeyPath:key
                           options:NSKeyValueObservingOptionInitial
                           context:nil];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    BOOL frameChange = NO;
    
    if ([keyPath isEqualToString:kControlLocationX]) {
        frameRect.origin.x = [[object valueForKeyPath:keyPath] doubleValue];
        frameChange = YES;
    } else if ([keyPath isEqualToString:kControlLocationY]) {
        frameRect.origin.y = [[object valueForKeyPath:keyPath] doubleValue];
        frameChange = YES;
    } else if ([keyPath isEqualToString:kControlWidth]) {
        frameRect.size.width = [[object valueForKeyPath:keyPath] doubleValue];
        frameChange = YES;
    } else if ([keyPath isEqualToString:kControlHeight]) {
        frameRect.size.height = [[object valueForKeyPath:keyPath] doubleValue];
        frameChange = YES;
    }
    
    if (frameChange) {
//        NSLog(@"%@ set frame to %@; scale %g", [self class], NSStringFromRect(frameRect), [self scale].width);
        [self setFrame:frameRect];
        [self setNeedsDisplay];
    }
}

- (void)setColor:(NSColor *)aColor {
    color = aColor;
    
    if (nil == [self cell]) return;
    [[self cell] setColor:aColor];
}

- (void) setColorKey:(NSString *)key {
    [[self cell] setColorKey:key];
}

+ (id) cellClass {
    return [CCCheckboxCell class];
}

- (id) initWithFrame:(NSRect)frameR {
    if (self = [self initWithFrame:frameRect colorKey:ccNormalColor]) {
        
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameR color:(NSColor *)aColor {
    if ([super initWithFrame:frameR]) {
        frameRect = frameR;
        [self setColor:aColor];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameR colorKey:(NSString *)aColorKey {
    if ([super initWithFrame:frameR]) {
        frameRect = frameR;
        [[self cell] setColorKey:aColorKey];
        color = [[self cell] color];
    }
    return self;
}

- (id)initWithModel:(CCESingleCheckModel *)model
{
    CCELocation *location = model.location;
    NSPoint where = NSMakePoint([location.locX doubleValue], [location.locY doubleValue]);
    NSSize size = NSMakeSize([location.width doubleValue], [location.height doubleValue]);
    NSRect rect = {where, size};
    
    if (location.colorCode != nil) {
        AppDelegate *appdel = [NSApp delegate];
        NSString *colKey = [appdel colorKeyForCode:[location.colorCode integerValue]];
        self = [self initWithFrame:rect colorKey:colKey];
    } else {
        NSColor *aColor = location.color;
        self = [self initWithFrame:rect color:aColor];
    }
    
        // model and view refer to each other
    [model setControlInView:self];
    [self setModelledControl:model];
    
    return self;
}

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget {
    BOOL retv = [super sendAction:theAction to:theTarget];
    
    if (parent) 
        [parent notify:self];
    
    return retv;
}

    // don't take keyboard input
- (BOOL) acceptsFirstResponder {
    return NO;
}

@end
