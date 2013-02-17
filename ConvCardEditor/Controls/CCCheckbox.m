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
#import "CommonStrings.h"
#import "NSControl+CCESetColorCode.h"
#import "CCELocationController.h"

@implementation CCCheckbox

@synthesize frameRect;
@synthesize parent;
@synthesize modelLocation;
@synthesize color;
@synthesize colorKey;
@synthesize modelledControl;
@synthesize locationController;

- (id)monitorModel:(CCEModelledControl *)model
{
    modelledControl = model;
    
        // monitoring
    locationController = [[CCELocationController alloc] initWithModel:model control:self];

    return locationController;
}

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

+ (id) cellClass {
    return [CCCheckboxCell class];
}

- (id) initWithFrame:(NSRect)frameR {
    if (self = [self initWithFrame:frameR colorKey:ccNormalColor]) {
        
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
        colorKey = aColorKey;
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
    
        // control model location refer to each other
    [self monitorModel:model];
    
    return self;
}

- (void)setColor:(NSColor *)aColor {
    color = aColor;
    if (nil != [self cell])
        [[self cell] setColor:aColor];
}

- (void) setColorKey:(NSString *)key {
    colorKey = key;
    if (nil != [self cell])
        [[self cell] setColorKey:key];
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
