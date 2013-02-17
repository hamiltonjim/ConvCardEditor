//
//  CCELocationController.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/30/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCELocationController.h"
#import "CCEMultiCheckModel.h"
#import "CCEModelledControl.h"
#import "CCELocation.h"
#import "CCctrlParent.h"
#import "CommonStrings.h"
#import "AppDelegate.h"
#include "fuzzyMath.h"

@interface CCELocationController ()

@property NSRect frameRect;
@property BOOL insetsRect;
@property NSPoint insetValue;

- (void)monitorLocation;
- (void)stopMonitoringLocation;
- (void)checkInsetsRect;

@end

@implementation CCELocationController

@synthesize modelledControl;
@synthesize watchedLocation;
@synthesize viewedControl;

@synthesize frameRect;
@synthesize insetsRect;
@synthesize insetValue;

- (void)monitorLocation
{
    if (watchedLocation == nil) {
        return;
    }
    
    [self checkInsetsRect];
    frameRect = [viewedControl frame];
    if (insetsRect) {
        frameRect = NSInsetRect(frameRect, insetValue.x, insetValue.y);
    }
    [[CommonStrings dimensionKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        [watchedLocation addObserver:self
                          forKeyPath:key
                             options:NSKeyValueObservingOptionInitial
                             context:nil];
    }];
    [watchedLocation addObserver:self forKeyPath:cceLocationColor options:0 context:nil];
    [watchedLocation addObserver:self forKeyPath:cceLocationColorCode options:0 context:nil];
}

- (void)stopMonitoringLocation
{
        // stop observing old location, if any
    if (watchedLocation != nil) {
        [[CommonStrings dimensionKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            [watchedLocation removeObserver:self forKeyPath:key];
        }];
        frameRect = NSZeroRect;
        
        [watchedLocation removeObserver:self forKeyPath:cceLocationColorCode];
        [watchedLocation removeObserver:self forKeyPath:cceLocationColor];
    }
}

- (void)checkInsetsRect
{
    insetsRect = [viewedControl respondsToSelector:@selector(insetModelledRect)];
    if (insetsRect) {
        insetValue = [viewedControl insetModelledRect];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    BOOL frameChange = NO;
    
    id value = [object valueForKeyPath:keyPath];
    CGFloat dvalue;
    
    if ([keyPath isEqualToString:kControlLocationX]) {
        dvalue = [value doubleValue];
        if (fuzzyCompare(frameRect.origin.x, dvalue)) {
            frameRect.origin.x = dvalue;
            frameChange = YES;
        }
    } else if ([keyPath isEqualToString:kControlLocationY]) {
        dvalue = [value doubleValue];
        if (fuzzyCompare(frameRect.origin.y, dvalue)) {
            frameRect.origin.y = dvalue;
            frameChange = YES;
        }
    } else if ([keyPath isEqualToString:kControlWidth]) {
        dvalue = [value doubleValue];
        if (fuzzyCompare(frameRect.size.width, dvalue)) {
            frameRect.size.width = dvalue;
            frameChange = YES;
        }
    } else if ([keyPath isEqualToString:kControlHeight]) {
        dvalue = [value doubleValue];
        if (fuzzyCompare(frameRect.size.height, dvalue)) {
            frameRect.size.height = dvalue;
            frameChange = YES;
        }
    } else if ([keyPath isEqualToString:cceLocationColor]) {
        if ([viewedControl respondsToSelector:@selector(setColor:)])
            [viewedControl setColor:value];
    } else if ([keyPath isEqualToString:cceLocationColorCode]) {
        if ([viewedControl respondsToSelector:@selector(setColorKey:)]) {
            NSInteger code = [value integerValue];
            [(AppDelegate *)[NSApp delegate] colorKeyForCode:code];
        }
    }
    
        // only call setFrame if there was a change
    if (frameChange) {
            //        NSLog(@"%@ set frame to %@; scale %g", [viewedControl class], NSStringFromRect(frameRect), [self scale].width);
        if (insetsRect) {
            NSRect visibleRect = NSInsetRect(frameRect, -insetValue.x, -insetValue.y);
            [viewedControl setFrame:visibleRect];
        } else {
            [viewedControl setFrame:frameRect];
        }
        [viewedControl setNeedsDisplay];
    }
}

- (id)initWithModel:(CCEModelledControl *)model
            control:(NSControl<CCDebuggableControl> *)ctrl
{
    if (self = [super init]) {
        if ([viewedControl conformsToProtocol:@protocol(CCctrlParent)]) {
            [NSException raise:@"WrongInitializer"
                        format:@"%@ needs indexed initializer", [ctrl class]];
        }
        
        modelledControl = model;
        viewedControl = ctrl;
        
        watchedLocation = (CCELocation *)model.location;
        [self monitorLocation];
    }
    
    return self;
}

- (id)initWithModel:(CCEModelledControl *)model
              index:(NSInteger)index
            control:(NSControl<CCDebuggableControl, CCctrlParent> *)ctrl
{
    if (self = [super init]) {
        modelledControl = model;
        NSArray *indexedControls = ctrl.controls;
        viewedControl = [indexedControls objectAtIndex:index - 1];
        
        if ([model respondsToSelector:@selector(locationWithIndex:)]) {
            watchedLocation = [(id)model locationWithIndex:index];
            [self monitorLocation];
        }
    }
    
    return self;
}

- (void)dealloc {
    [self stopMonitoringLocation];
}

- (void)setWatchedLocation:(CCELocation *)location
{
    [self stopMonitoringLocation];
    watchedLocation = location;
    [self monitorLocation];
}

@end
