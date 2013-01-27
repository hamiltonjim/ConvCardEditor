//
//  CCEControlsView.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/14/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/NSNibLoading.h>
#import "CCDebuggableControl.h"

#define roundedRect(A) NSIntegralRectWithOptions(A, NSAlignAllEdgesNearest)

@class CCECardTypeEditorController;
@class CCEControlsSuperView;

@interface CCEControlsViewController : NSView

@property IBOutlet CCEControlsSuperView *view;
@property (weak) IBOutlet NSView *observedView;
@property (weak) NSManagedObject *cardType;
@property NSMutableArray *controls;
@property (weak, readonly, nonatomic) NSControl <CCDebuggableControl> *selectedControl;
@property (weak) CCECardTypeEditorController *controller;

@property NSInteger controlType;

@property BOOL editMode;

- (void)load:(NSManagedObject *)type;
- (void)load:(NSManagedObject *)type editMode:(BOOL)editing;

- (void)viewMouseDown:(NSEvent *)theEvent;
- (void)viewMouseUp:(NSEvent *)theEvent;

    // returns YES if drag events are desired
- (BOOL)viewMouseDragged:(NSEvent *)theEvent;

- (void)setSelection:(NSControl <CCDebuggableControl> *)aControl;
- (IBAction)deleteSelected:(id)sender;

    /* When a control is clicked, treat it as selecting it as an object,
        as if in a drawing layout. */
- (IBAction)layoutClick:(id)sender;

- (void)setGridState:(BOOL)state;

@end
