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
@class CCEControlTest;
@class FixedNSImageView;
@class CCEToolPaletteController;
@class CCEIncrementBindableStepper;

@interface CCEControlsViewController : NSResponder {
    IBOutlet __weak NSButton *testControlButton;
    IBOutlet __weak NSButton *stopTestControlButton;
}

@property IBOutlet NSWindow *window;
@property (weak) IBOutlet CCEControlsSuperView *view;
@property NSManagedObject *cardType;
@property NSManagedObject *partnership;
@property NSMutableArray *controls;
@property (weak, readonly, nonatomic) NSControl <CCDebuggableControl> *selectedControl;
@property (weak) CCECardTypeEditorController *controller;

@property NSInteger controlType;
@property (nonatomic) BOOL controlVariant;

@property BOOL editMode;
@property (readonly) NSNumber *isTesterForSelected;

@property (weak) IBOutlet FixedNSImageView *cardImageView;

    // info panel
@property IBOutlet NSPanel *infoPanel;
@property (weak) IBOutlet NSColorWell *controlColorWell;
@property (weak) IBOutlet NSMatrix *stdControlColorGroup;

@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSTextField *xField;
@property (weak) IBOutlet NSTextField *yField;
@property (weak) IBOutlet NSTextField *widthField;
@property (weak) IBOutlet NSTextField *heightField;

@property (weak) IBOutlet CCEIncrementBindableStepper *xPosStepper;
@property (weak) IBOutlet CCEIncrementBindableStepper *yPosStepper;
@property (weak) IBOutlet CCEIncrementBindableStepper *widthStepper;
@property (weak) IBOutlet CCEIncrementBindableStepper *heightStepper;

@property (weak) IBOutlet NSObjectController *selectedObject;
@property (weak) IBOutlet NSObjectController *locationObject;

@property (nonatomic) NSNumber *canSquare;
@property (nonatomic) NSNumber *square;

@property (weak) IBOutlet CCEToolPaletteController *toolsPaletteController;

@property (nonatomic) BOOL gridState;
@property (readonly) NSString *gridStateLabel;

- (void)resignFront;

- (void)load:(NSManagedObject *)type for:(NSManagedObject *)partnership;
- (void)load:(NSManagedObject *)type editMode:(BOOL)editing;

- (void)viewMouseDown:(NSEvent *)theEvent;
- (void)viewMouseUp:(NSEvent *)theEvent;

    // returns YES if drag events are desired
- (BOOL)viewMouseDragged:(NSEvent *)theEvent;

    // undo & redo
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

- (void)setSelection:(NSControl <CCDebuggableControl> *)aControl;
- (void)setSelection:(NSControl<CCDebuggableControl> *)aControl index:(NSInteger)index;
- (IBAction)deleteSelected:(id)sender;
- (void)deleteSelected:(id)sender forceAll:(BOOL)force;

    /* When a control is clicked, treat it as selecting it as an object,
        as if in a drawing layout. */
- (IBAction)layoutClick:(id)sender;

- (void)setGridState:(BOOL)state;

- (IBAction)testControl:(id)sender;
- (IBAction)cancelTestControl:(id)sender;
- (CCEControlTest *)testerForSelected;

- (IBAction)testAllControls:(id)sender;
- (IBAction)stopAllControlTesters:(id)sender;

- (void)setImageWithURL:(NSURL *)url;
- (NSSize)imageSize;

- (IBAction)absoluteScale:(id)sender;
- (IBAction)scaleZero:(id)sender;
- (void)rescale:(double)newScale;

- (IBAction)scaleLarger:(id)sender;
- (IBAction)scaleSmaller:(id)sender;

- (IBAction)scaleToWindow:(id)sender;

    // arrow key handling
- (void)nudgeLeft:(CGFloat)multiplier;
- (void)nudgeRight:(CGFloat)multiplier;
- (void)nudgeUp:(CGFloat)multiplier;
- (void)nudgeDown:(CGFloat)multiplier;

- (void)growH:(CGFloat)multiplier;
- (void)growV:(CGFloat)multiplier;
- (void)shrinkH:(CGFloat)multiplier;
- (void)shrinkV:(CGFloat)multiplier;

    // add parts to multi-part control
- (IBAction)addParts:(id)sender;

    // control info
- (IBAction)controlInfo:(id)sender;

- (IBAction)editControlName:(id)sender;
- (IBAction)editControlPosition:(id)sender;
- (IBAction)editControlColor:(id)sender;

- (IBAction)duplicateControl:(id)sender;

- (IBAction)showWindow:(id)sender;

- (IBAction)squareKeeper:(id)sender;

- (IBAction)setControlColorCode:(id)sender;
- (IBAction)setNormalColor:(id)sender;
- (IBAction)setAlertColor:(id)sender;
- (IBAction)setAnnounceColor:(id)sender;

- (IBAction)numericSetting:(id)sender;

- (IBAction)doSetNext:(id)sender;

    // overall control
- (IBAction)updateUnits:(id)sender;

- (IBAction)toggleGridState:(id)sender;

- (IBAction)chooseControlType:(id)sender;

- (void)chooseNextControl;

- (void)registerFirstResponder:(NSView *)responder;
- (void)unregisterFirstResponder:(NSView *)responder;

    // tools palette
- (IBAction)chooseControlByTag:(id)sender;

    // debug
- (IBAction)highlightControls:(id)sender;
- (IBAction)showSelectedControlInfo:(id)sender;
- (IBAction)showResponderChain:(id)sender;

+ (NSInteger)count;

- (IBAction)keyViewLoop:(id)sender;

@end
