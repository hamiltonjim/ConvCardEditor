//
//  CCDebuggableControl.h
//  CCardX
//
//  Created by Jim Hamilton on 9/11/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCDebuggableControl.h,v 1.2 2010/12/21 05:13:26 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCDebuggableControlEnable.h"
#import "CCctrlParent.h"
#import "CCEValueBindingTransformer.h"

@class CCEModelledControl;

    // Protocol to allow a globally enabled, debuggable control.  It's
    // up to the conforming control cell how to draw debug mode; the
    // main thing is, debug mode can be turned on individually, then
    // cut off globally.  The extern declared below is defined in
    // CCDebuggableControlEnable.m; set the value to NO to turn off
    // debug mode everywhere.

enum EDebugState {
    kOff,
    kShowUnselected,    // shade
    kShowSelected,      // shade & highlight
    kShowSelectedOther  // shade & highlight, but as part of a larger control
    };

@protocol CCDebuggableControl

@required

    // observe currently edited location, and update
- (id)monitorModel:(CCEModelledControl *)model;

- (void)setDebugMode:(int)newDebugMode;

@optional

    // name of an NSValueTransformer for converting the value binding
- (NSString *)valueBindingTransformerName;

- (id)monitorModel:(CCEModelledControl *)model index:(NSUInteger)index;

@property (weak, nonatomic) id <CCctrlParent> parent;

    // observe currently edited location, and update
    // usually a CCELocationController; sometimes an array...
@property (nonatomic) id locationController;
@property (weak, nonatomic) CCEModelledControl *modelledControl;

    // colors (monitored for changes by a separate controller)
@property (nonatomic) NSColor *color;
@property (nonatomic) NSString *colorKey;

    // reindexing is delegated to parent control (if any; irrelevant if no parent)
- (BOOL)isReindexing;
- (NSInteger)reindexFrom:(NSUInteger)fromIndex
                      to:(NSUInteger)toIndex
                   error:(NSError *__autoreleasing *)error;

    // Break any external monitoring of a control (as, when it's window is closed).
    // A control only needs to implement this if it can be built from a (CoreData)
    // model.
- (void)stopMonitoring;


    // "debugMode" is the way to show controls in a view that is being edited; a
    // "debugged" control is one of Unselected, Selected or SelectedOther (see
    // EDebugState, above).
- (int) debugMode;

    // If an editable control is a different size from its fixed counterpart,
    // return the amout by which the modelled location should be inset (i.e.,
    // by which the editable version is larger on each side)
- (NSPoint)insetModelledRect;

- (void)advanceTest;
- (void)resetTest;

    // for a multiple part control:  show the part with the selected index
    // as selected, and the other parts as "selected-other"
- (void)setDebugMode:(int)newDebugMode index:(NSInteger)index;


@end
