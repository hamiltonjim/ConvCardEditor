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
#import "fuzzyMath.h"
#import "NSView+ScaleUtilities.h"
#import "CCMatrix.h"

static NSInteger s_count;

@interface CCELocationController ()

@property NSRect frameRect;
@property BOOL insetsRect;
@property NSPoint insetValue;

@property (atomic) BOOL monitorActive;

@property id zoomObserver;
@property NSOperationQueue *opQ;

@property NSControl *parentCtl;

- (void)checkInsetsRect;

- (void)setControlFrame;
- (void)doReindex:(NSDictionary *)change;

+ (NSArray *)monitorKeypaths;
+ (NSUInteger)optionsForKeypath:(NSString *)keypath;

@end

static NSArray *kMonitorKeypaths;

@implementation CCELocationController

@synthesize modelledControl;
@synthesize watchedLocation;
@synthesize viewedControl;

@synthesize monitorActive;

@synthesize frameRect;
@synthesize insetsRect;
@synthesize insetValue;

@synthesize zoomObserver;
@synthesize opQ;

@synthesize parentCtl;

+ (NSArray *)monitorKeypaths
{
    @synchronized(self) {
        if (kMonitorKeypaths == nil) {
                // objects (keypaths) to monitor:
            NSMutableArray *keypaths = [NSMutableArray arrayWithArray:@[
                                        cceLocationColorCode, cceLocationColor, cceLocationIndex]];
            [keypaths addObjectsFromArray:[CommonStrings dimensionKeys]];
            kMonitorKeypaths = keypaths;
        }
    return kMonitorKeypaths;
    }
}

+ (NSUInteger)optionsForKeypath:(NSString *)keypath
{
    if ([keypath isEqualToString:cceLocationIndex]) {
        return NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    }
    
    return NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
}

- (void)monitorLocation
{
    if (watchedLocation == nil) {
        return;
    }
    
    @synchronized(self) {
        if (monitorActive)
            return;
        
        [self checkInsetsRect];
        frameRect = [viewedControl frame];
        if (insetsRect) {
            frameRect = NSInsetRect(frameRect, insetValue.x, insetValue.y);
        }
        [[[self class] monitorKeypaths]
         enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            NSUInteger options = [[self class] optionsForKeypath:key];
            [watchedLocation addObserver:self
                              forKeyPath:key
                                 options:options
                                 context:nil];
        }];
        
        if (opQ == nil) {
            opQ = [NSOperationQueue new];
        }
        zoomObserver = [[NSNotificationCenter defaultCenter] addObserverForName:cceZoomFactorChanged
                                                                         object:nil
                                                                          queue:opQ
                                                                     usingBlock:^(NSNotification *note) {
            [self setControlFrame];
        }];
        monitorActive = YES;
    }
}

- (void)stopMonitoringLocation
{
    if (self.monitorActive == NO)
        return;
        // stop observing old location, if any
    if (watchedLocation != nil) {
        [[[self class] monitorKeypaths] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            [watchedLocation removeObserver:self forKeyPath:key];
        }];
        frameRect = NSZeroRect;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:zoomObserver];
    zoomObserver = nil;
    self.monitorActive = NO;
}

- (void)checkInsetsRect
{
    insetsRect = [viewedControl respondsToSelector:@selector(insetModelledRect)];
    if (insetsRect) {
        insetValue = [viewedControl insetModelledRect];
    }
}

- (void)setControlFrame
{
    NSRect drawRect = [NSView defaultScaleRect:frameRect];
    NSRect visibleRect;
    if (insetsRect) {
        visibleRect = NSInsetRect(drawRect, -insetValue.x, -insetValue.y);
        [viewedControl setFrame:visibleRect];
    } else if (parentCtl != nil) {
        NSPoint parentOrigin = parentCtl.frame.origin;
        visibleRect = NSOffsetRect(drawRect, -parentOrigin.x, -parentOrigin.y);
        [viewedControl setFrame:visibleRect];
    } else {
        [viewedControl setFrame:drawRect];
    }
    [viewedControl setNeedsDisplay];
}

- (void)doReindex:(NSDictionary *)change
{
    if ([viewedControl respondsToSelector:@selector(isReindexing)] && [viewedControl isReindexing]) {
        return;
    }
    
        // this can happen when a non-indexed control is deleted, as the index changes from 0 to null.
    if (![viewedControl respondsToSelector:@selector(parent)]) {
        return;
    }
    
        // reindex only makes sense for a parent control's child controls
    if (viewedControl.parent == nil)
        return;
    
    NSNumber *valNumber = [change valueForKey:NSKeyValueChangeOldKey];
    if (valNumber == nil || [valNumber isEqualTo:[NSNull null]])
        return;
    NSUInteger oldIdx = valNumber.integerValue;
    
    valNumber = [change valueForKey:NSKeyValueChangeNewKey];
    if (valNumber == nil || [valNumber isEqualTo:[NSNull null]])
        return;
    NSUInteger newIdx = valNumber.integerValue;
    
    NSError *err;
    [viewedControl reindexFrom:oldIdx to:newIdx error:&err];
    if (err) {
        [[NSNotificationCenter defaultCenter] postNotificationName:errorNotify
                                                            object:viewedControl.window
                                                          userInfo:@{errorNotify: err}];
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
            NSString *colorKey = [(AppDelegate *)[NSApp delegate] colorKeyForCode:code];
            [viewedControl setColorKey:colorKey];
        }
    } else if ([keyPath isEqualToString:cceLocationIndex]) {
        [self doReindex:change];
    }
    
        // only call setFrame if there was a change
    if (frameChange) {
        [self setControlFrame];
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
    
    ++s_count;
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
        parentCtl = ctrl;
        
        if ([model respondsToSelector:@selector(locationWithIndex:)]) {
            watchedLocation = [(id)model locationWithIndex:index];
            [self monitorLocation];
        }
    }
    
    ++s_count;
    return self;
}

- (void)dealloc {
    --s_count;
    [self stopMonitoringLocation];
}

- (void)setWatchedLocation:(CCELocation *)location
{
    [self stopMonitoringLocation];
    watchedLocation = location;
    [self monitorLocation];
}

#pragma mark DEBUG

+ (NSInteger)count
{
    return s_count;
}

@end
