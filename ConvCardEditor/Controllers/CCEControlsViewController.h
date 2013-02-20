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
    IBOutlet NSButton *testControlButton;
    IBOutlet NSButton *stopTestControlButton;
}

@property IBOutlet NSWindow *window;
@property IBOutlet CCEControlsSuperView *view;
@property (weak) IBOutlet NSView *observedView;
@property (weak) NSManagedObject *cardType;
@property (weak) NSManagedObject *partnership;
@property NSMutableArray *controls;
@property (weak, readonly, nonatomic) NSControl <CCDebuggableControl> *selectedControl;
@property (weak) CCECardTypeEditorController *controller;

@property NSInteger controlType;
@property (nonatomic) BOOL controlVariant;

@property BOOL editMode;
@property (readonly) NSNumber *isTesterForSelected;

@property IBOutlet FixedNSImageView *cardImageView;

    // info panel
@property IBOutlet NSPanel *infoPanel;
@property IBOutlet NSColorWell *controlColorWell;
@property IBOutlet NSMatrix *stdControlColorGroup;

@property IBOutlet NSTextField *nameField;
@property IBOutlet NSTextField *xField;
@property IBOutlet NSTextField *yField;
@property IBOutlet NSTextField *widthField;
@property IBOutlet NSTextField *heightField;

@property IBOutlet CCEIncrementBindableStepper *xPosStepper;
@property IBOutlet CCEIncrementBindableStepper *yPosStepper;
@property IBOutlet CCEIncrementBindableStepper *widthStepper;
@property IBOutlet CCEIncrementBindableStepper *heightStepper;

@property IBOutlet NSObjectController *selectedObject;
@property IBOutlet NSObjectController *locationObject;

@property (nonatomic) NSNumber *canSquare;
@property (nonatomic) NSNumber *square;

@property IBOutlet CCEToolPaletteController *toolsPaletteController;

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

    /* When a control is clicked, treat it as selecting it as an object,
        as if in a drawing layout. */
- (IBAction)layoutClick:(id)sender;

- (void)setGridState:(BOOL)state;

- (IBAction)testControl:(id)sender;
- (IBAction)cancelTestControl:(id)sender;
- (CCEControlTest *)testerForSelected;

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


- (IBAction)controlInfo:(id)sender;

- (IBAction)editControlName:(id)sender;
- (IBAction)editControlPosition:(id)sender;
- (IBAction)editControlColor:(id)sender;

- (IBAction)showWindow:(id)sender;

- (IBAction)squareKeeper:(id)sender;

- (IBAction)setControlColorCode:(id)sender;

- (IBAction)updateUnits:(id)sender;

- (IBAction)toggleGridState:(id)sender;

- (IBAction)chooseControlType:(id)sender;

- (void)chooseNextControl;

    // tools palette
- (IBAction)chooseControlByTag:(id)sender;

    // debug
- (IBAction)showSelectedControlInfo:(id)sender;
- (IBAction)showResponderChain:(id)sender;

@end
