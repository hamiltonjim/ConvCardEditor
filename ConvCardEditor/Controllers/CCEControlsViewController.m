//
//  CCEControlsView.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/14/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//


#import "CCEControlsViewController.h"
#import "NSView+ScaleUtilities.h"
#import "CCEControlsSuperView.h"
#import "CCEManagedObjectModels.h"
#import "CommonStrings.h"
#import "CCCheckbox.h"
#import "CCBoxMatrix.h"
#import "CCLeadChoice.h"
#import "CCLeadChoiceMatrix.h"
#import "CCEModelledControl.h"
#import "CCELocation.h"
#import "CCESingleCheckModel.h"
#import "CCEMultiCheckModel.h"
#import "CCECardTypeEditorController.h"
#import "CCEEntityFetcher.h"
#import "NSView+ScaleUtilities.h"
#import "CCESizableTextField.h"
#import "CCETextModel.h"
#import "CCTextField.h"
#import "CCEControlTest.h"
#import "CCELocationController.h"
#import "FixedNSImageView.h"
#import "AppDelegate.h"
#import "CCEColorBindableButtonCell.h"
#import "CCEToolPaletteController.h"
#import "CCEIncrementBindableStepper.h"
#import "CCEValueBinder.h"
#import "CCEDuplicator.h"

#import "math.h"
#include "fuzzyMath.h"

static NSInteger s_count;

static NSString *showGrid;
static NSString *hideGrid;

static NSArray *defaultsList;

@interface CCEControlsViewController ()

@property (weak, readwrite, nonatomic) NSControl <CCDebuggableControl> *selectedControl;
@property (nonatomic) NSMutableSet *cardSettings;
@property (nonatomic) double zoom;

@property NSEvent *mouseDownEvent;

@property (readwrite) NSNumber *isTesterForSelected;

    // for controls of indeterminate size, that need to be framed in the whole window
    // (building from models, this is before the view is sized...)
@property NSRect wholeFrame;

@property (readwrite) NSString *gridStateLabel;

@property CGFloat stepIncrementValue;

@property NSMutableSet *bindings;

@property BOOL duplicatingObjectsState;
@property NSSize duplicatingDiffLocation;

- (void)observeDefaults;
- (void)unobserveDefaults;

- (void)selectControlObject:(CCEModelledControl *)object;
- (void)selectControlObject:(CCEModelledControl *)object selIndex:(NSInteger)index;

- (void)visualSelect:(NSControl<CCDebuggableControl> *)aControl;
- (void)visualSelect:(NSControl<CCDebuggableControl> *)aControl index:(NSInteger)index;
- (void)targetSelf:(NSControl <CCDebuggableControl> *)control;

- (NSPoint)checkBoxLowerLeft:(NSPoint)where;
- (CCCheckbox *)createCheckboxAt:(NSPoint)where;
- (CCCheckbox *)createCheckboxAt:(NSPoint)where size:(NSSize)size;
- (void)createSingleCheckbox:(NSEvent *)theEvent;

- (void)createMultiCheckbox:(NSEvent *)theEvent;
- (void)addBoxToMultiCheckbox:(NSEvent *)theEvent;

- (void)createLeadCircle:(NSEvent *)theEvent;
- (void)addCircleToLeadCircles:(NSEvent *)theEvent;

- (void)createTextControl:(NSEvent *)theEvent;

- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl;
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
                                at:(NSPoint)where;
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
                         withIndex:(NSUInteger)index;
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
                                at:(NSPoint)where
                         withIndex:(NSUInteger)index;
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
                                at:(NSPoint)where
                          withSize:(NSSize)size;
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
                                at:(NSPoint)where
                         withIndex:(NSUInteger)index
                          withSize:(NSSize)size;

- (CCEModelledControl *)modelledControlFor:(NSControl <CCDebuggableControl> *)ctl;

- (NSControl <CCDebuggableControl> *)controlFromModel:(CCEModelledControl *)model;
- (CCCheckbox *)checkboxFromModel:(CCEModelledControl *)model;
- (CCMatrix *)matrixFromModel:(CCEMultiCheckModel *)model;
- (id)textBoxFromModel:(CCETextModel *)model;

- (void)flashControlTester:(CCEControlTest *)tester;

- (void)infoPanelInit;

- (void)offsetObjectLocationX:(CGFloat)xOffset andY:(CGFloat)yOffset;
- (void)growObjectWidth:(CGFloat)deltaW andHeight:(CGFloat)deltaH;

- (void)stopMonitoringLocations;

- (void)errorDisplay:(NSNotification *)notify;
- (void)sheetEnded:(NSWindow *)sheet
        returnCode:(int)returnCode
       contextInfo:(void  *)contextInfo;

@end

typedef struct LocalDefaults {
    double boxWidth;
    double boxHeight;
    
    double ovalWidth;
    double ovalHeight;
    
    bool defaultsValid;
} LocalDefaults;
static LocalDefaults localDflts = {0, 0, 0, 0, false};

void loadDefaults() {
    if (localDflts.defaultsValid)
        return;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    BOOL squares = [ud boolForKey:ccChecksAreSquare];
    localDflts.boxWidth = [ud doubleForKey:ccCheckboxWidth];
    localDflts.boxHeight = squares ? localDflts.boxWidth : [ud doubleForKey:ccCheckboxHeight];
    
    BOOL circles = [ud boolForKey:ccCirclesAreRound];
    localDflts.ovalWidth = [ud doubleForKey:ccCircleWidth];
    localDflts.ovalHeight = circles ? localDflts.ovalWidth : [ud doubleForKey:ccCircleHeight];
}

    // scale the rectangle DIVIDING each component by scaleBy
NSRect scaleRect(NSRect rect, double scaleBy) {
    if (scaleBy == 0)
        return NSZeroRect;
    
    rect.origin.x /= scaleBy;
    rect.origin.y /= scaleBy;
    rect.size.width /= scaleBy;
    rect.size.height /= scaleBy;
    
    return rect;
}

NSPoint roundPt(NSPoint pt)
{
    pt.x = round(pt.x);
    pt.y = round(pt.y);
    
    return pt;
}

@implementation CCEControlsViewController

@synthesize window;
@synthesize view;
@synthesize cardType;
@synthesize partnership;
@synthesize cardSettings;
@synthesize zoom;

@synthesize wholeFrame;

@synthesize observedView;
@synthesize controls;
@synthesize selectedControl;

@synthesize controlType;
@synthesize controlVariant;

@synthesize editMode;
@synthesize isTesterForSelected;

@synthesize controller;

@synthesize mouseDownEvent;

@synthesize cardImageView;

    // info panel
@synthesize infoPanel;
@synthesize controlColorWell;
@synthesize stdControlColorGroup;

@synthesize nameField;
@synthesize xField;
@synthesize yField;
@synthesize widthField;
@synthesize heightField;

@synthesize xPosStepper;
@synthesize yPosStepper;
@synthesize widthStepper;
@synthesize heightStepper;

@synthesize selectedObject;
@synthesize locationObject;

@synthesize canSquare;
@synthesize square;

@synthesize gridState;
@synthesize gridStateLabel;

@synthesize toolsPaletteController;

@synthesize stepIncrementValue;

@synthesize bindings;

@synthesize duplicatingObjectsState;
@synthesize duplicatingDiffLocation;

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:cceStepIncrement];
    
    --s_count;
}

#pragma mark INITIALIZATION
+ (void)initialize
{
    if (self == [CCEControlsViewController class]) {
        showGrid = NSLocalizedString(@"Show Grid", @"show grid label");
        hideGrid = NSLocalizedString(@"Hide Grid", @"hide grid label");
        
        defaultsList = @[
                         ccDimensionUnit,
                         ccChecksAreSquare, ccCheckboxWidth, ccCheckboxHeight,
                         ccCirclesAreRound, ccCircleWidth, ccCircleHeight
                         ];
    }
}

- (void)awakeFromNib
{
    ++s_count;
    
    [cardImageView setImageAlignment:NSImageAlignBottomLeft];
    [cardImageView setZoomFactor:[NSView defaultScale]];
    [cardImageView setMaxZoom:[[NSUserDefaults standardUserDefaults] valueForKey:cceMaximumScale]];
    [cardImageView setMinZoom:[[NSUserDefaults standardUserDefaults] valueForKey:cceMinimumScale]];
    
    [cardImageView setAutoresizingMask:NSViewWidthSizable + NSViewHeightSizable];
    [cardImageView setAutoresizesSubviews:YES];
    
        // resizing handled manually
    [view setAutoresizesSubviews:NO];
    
    [self observeDefaults];
    
    [infoPanel setNextResponder:window];
    
        // scale
    NSNumber *scaleNumber = [[NSUserDefaults standardUserDefaults] valueForKey:ccDefaultScale];
    [self absoluteScale:scaleNumber];
    
    self.gridState = [[NSUserDefaults standardUserDefaults] boolForKey:cceGridState];
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [xPosStepper observeIncrementFrom:ud keypath:cceStepIncrement];
    [yPosStepper observeIncrementFrom:ud keypath:cceStepIncrement];
    [widthStepper observeIncrementFrom:ud keypath:cceStepIncrement];
    [heightStepper observeIncrementFrom:ud keypath:cceStepIncrement];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:cceStepIncrement
                                               options:NSKeyValueObservingOptionInitial
                                               context:NULL];
    
    [self infoPanelInit];
    [self showWindow:self];
    
    bindings = [NSMutableSet set];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(errorDisplay:)
                                                 name:errorNotify
                                               object:window];
}

- (IBAction)showWindow:(id)sender
{
    [window makeKeyAndOrderFront:sender];
    [window setNextResponder:toolsPaletteController.toolsPalette];
}

#pragma mark KVO
    // start observing a list of preferences
- (void)observeDefaults
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [defaultsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ud addObserver:self
             forKeyPath:obj
                options:NSKeyValueObservingOptionInitial
                context:nil];
    }];
}

- (void)unobserveDefaults
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [defaultsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ud removeObserver:self
             forKeyPath:obj];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:ccDimensionUnit]) {
        [view setNeedsDisplay:YES];
    } else if ([keyPath isEqualToString:kTesterIsRunning]) {
            // if the change in running status is for the SELECTED control...
        CCEControlTest *tester = object;
        if (tester.control == selectedControl) {
            [self flashControlTester:tester];
        }
    } else if ([keyPath isEqualToString:cceStepIncrement]) {
        stepIncrementValue = [[NSUserDefaults standardUserDefaults] doubleForKey:keyPath];
    } else {
            // catch-all is for control sizes
        localDflts.defaultsValid = false;
    }
}

#pragma mark MOUSE EVENTS
- (void)viewMouseUp:(NSEvent *)theEvent
{
    switch (controlType) {
        case kPointerControl:
            [self setSelection:nil];
            break;
            
        case kSingleCheckboxControl:
            [self createSingleCheckbox:theEvent];
            break;
            
        case kMultiCheckboxControl:
            [self createMultiCheckbox:theEvent];
            break;
            
        case kMultiCheckboxControl + kControlVariant:
            [self addBoxToMultiCheckbox:theEvent];
            break;
            
        case kTextControl:
            [self createTextControl:theEvent];
            break;
            
        case kCircleChoiceControl:
            [self createLeadCircle:theEvent];
            break;
            
        case kCircleChoiceControl + kControlVariant:
            [self addCircleToLeadCircles:theEvent];
            break;
        
        default:
            NSLog(@"Handler for type %ld not implemented", controlType);
            break;
    }
    
    [self chooseNextControl];
}

- (void)viewMouseDown:(NSEvent *)theEvent
{
    mouseDownEvent = theEvent;
}

    // Returns YES if drag tracking is desired.  Currently, only to
    // create a text field.
- (BOOL)viewMouseDragged:(NSEvent *)theEvent
{
    switch (controlType) {
        case kTextControl:
            return YES;
            break;
            
        default:
            break;
    }
    
    return NO;
}

#pragma mark KEY EVENTS

- (void)offsetObjectLocationX:(CGFloat)xOffset andY:(CGFloat)yOffset
{
    CCELocation *selectedLocation = locationObject.content;
    if (selectedLocation == nil) {
        return;
    }
    
    CGFloat coordinate = selectedLocation.locX.doubleValue;
    selectedLocation.locX = [NSNumber numberWithDouble:(coordinate + xOffset)];
    
    coordinate = selectedLocation.locY.doubleValue;
    selectedLocation.locY = [NSNumber numberWithDouble:(coordinate + yOffset)];
}

- (void)nudgeUp:(CGFloat)multiplier
{
    CGFloat step = stepIncrementValue * multiplier;
    [self offsetObjectLocationX:0.0 andY:step];
    duplicatingDiffLocation.height += step;
}

- (void)nudgeDown:(CGFloat)multiplier
{
    CGFloat step = stepIncrementValue * multiplier;
    [self offsetObjectLocationX:0.0 andY:-step];
    duplicatingDiffLocation.height -= step;
}

- (void)nudgeLeft:(CGFloat)multiplier
{
    CGFloat step = stepIncrementValue * multiplier;
    [self offsetObjectLocationX:-step andY:0.0];
    duplicatingDiffLocation.width -= step;
}

- (void)nudgeRight:(CGFloat)multiplier
{
    CGFloat step = stepIncrementValue * multiplier;
    [self offsetObjectLocationX:step andY:0.0];
    duplicatingDiffLocation.width += step;
}

- (void)growObjectWidth:(CGFloat)deltaW andHeight:(CGFloat)deltaH
{
    CCELocation *selectedLocation = locationObject.content;
    if (selectedLocation == nil) {
        return;
    }
    
        // don't shrink below 1 point
    CGFloat sizeValue = selectedLocation.width.doubleValue;
    sizeValue = MAX(sizeValue + deltaW, 1.0);
    selectedLocation.width = [NSNumber numberWithDouble:sizeValue];
    
    sizeValue = selectedLocation.height.doubleValue;
    sizeValue = (MAX(sizeValue + deltaH, 1.0));
    selectedLocation.height = [NSNumber numberWithDouble:sizeValue];
}

- (void)growH:(CGFloat)multiplier
{
    [self growObjectWidth:stepIncrementValue * multiplier andHeight:0.0];
}

- (void)growV:(CGFloat)multiplier
{
    [self growObjectWidth:0.0 andHeight:stepIncrementValue * multiplier];
}

- (void)shrinkH:(CGFloat)multiplier
{
    [self growObjectWidth:-stepIncrementValue * multiplier andHeight:0.0];
}

- (void)shrinkV:(CGFloat)multiplier
{
    [self growObjectWidth:0.0 andHeight:-stepIncrementValue * multiplier];
}

#pragma mark SELECTION MODE

- (IBAction)chooseControlType:(id)sender
{
    static int errorStage = 0;
    
    NSInteger ccType = [sender tag];
    if (controlVariant) {
        ccType += kControlVariant;
    }
    controlType = (int)ccType;
    switch (ccType) {
        case kPointerControl:
        case kTextControl:
        case kSingleCheckboxControl:
        case kMultiCheckboxControl:
        case kCircleChoiceControl:
            errorStage = 0;
            break;
            
        case kMultiCheckboxControl + kControlVariant:
        case kCircleChoiceControl + kControlVariant:
                // make sure state is valid!
        {
            CCEModelledControl *control = selectedObject.content;
            if (control == nil || !control.isIndexed) {
                NSBeep();
                if (++errorStage >= 2) {
                        // error window
                    
                    controlType = kPointerControl;
                }
            } else {
                errorStage = 0;
            }
        }
            break;
            
        default:
            break;
    }
    
    
}

- (void)chooseNextControl
{
    [toolsPaletteController chooseNextControl];
}

- (IBAction)chooseControlByTag:(id)sender
{
        // forward to the tools palette
    [toolsPaletteController chooseControlByTag:sender];
}

#pragma mark SELECTION

- (void)visualSelect:(NSControl<CCDebuggableControl> *)aControl
{
    [self visualSelect:aControl index:0];
}

- (void)visualSelect:(NSControl<CCDebuggableControl> *)aControl index:(NSInteger)index
{
    if ([self testerForSelected] == nil) {
        [selectedControl setDebugMode:kShowUnselected];
    }
    
    self.selectedControl = aControl;
    [self flashControlTester:[self testerForSelected]];
    
    if ([self testerForSelected] == nil) {
        if ([selectedControl respondsToSelector:@selector(setDebugMode:index:)]) {
            [selectedControl setDebugMode:kShowSelected index:index];
        } else {
            [selectedControl setDebugMode:kShowSelected];
        }
    }
}

- (void)load:(NSManagedObject *)type for:(NSManagedObject *)partnershipObj
{
    partnership = partnershipObj;
    [self load:type editMode:NO];
}
- (void)load:(NSManagedObject *)type editMode:(BOOL)editing
{
    self.editMode = editing;
    self.cardType = type;
    self.cardSettings = [type mutableSetValueForKey:@"settings"];
    
    controls = [NSMutableArray array];
    
    NSString *wTitle;
    if (editMode) {
        wTitle = NSLocalizedString(@"Convention Card Template \u2014 %@",
                                   @"Title template for style editing (\u2014 is mdash)");
        wTitle = [NSString stringWithFormat:wTitle, cardType.cardName];
        
        [toolsPaletteController show];
    } else {
        wTitle = NSLocalizedString(@"Convention Card for %@", @"title template for partnership");
        wTitle = [NSString stringWithFormat:wTitle, partnership.partnershipName];
        
//        [toolsPaletteController hide];
    }
    [window setTitle:wTitle];
    
        // target rect
    wholeFrame = NSMakeRect(0.0, 0.0, type.width.doubleValue, type.height.doubleValue);
    
        // load existing controls
    [cardSettings enumerateObjectsUsingBlock:^(CCEModelledControl *obj, BOOL *stop) {
        [self controlFromModel:obj];
    }];
}

- (void)setSelection:(NSControl<CCDebuggableControl> *)aControl
{
    [self setSelection:aControl index:0];
}

- (void)setSelection:(NSControl<CCDebuggableControl> *)aControl index:(NSInteger)index
{
    if (!editMode)
        return;
    
    duplicatingObjectsState = NO;
    
    self.mouseDownEvent = nil;
    
    [self visualSelect:aControl index:index];
    self.selectedControl = aControl;
    [window makeFirstResponder:aControl];
    
    [self selectControlObject:[self modelledControlFor:aControl] selIndex:index];
    
        // if object is under test, note that
    [self flashControlTester:[CCEControlTest testerForControl:aControl]];
    if (isTesterForSelected.boolValue) {
        [aControl setDebugMode:kOff];
    }
}

- (IBAction)deleteSelected:(id)sender
{
    [self deleteSelected:sender forceAll:NO];
}

- (void)deleteSelected:(id)sender forceAll:(BOOL)force
{
    self.mouseDownEvent = nil;
    
    if (selectedControl == nil) {
        return;
    }
        // if the control is part of a matrix, delete it from the matrix
    if (!force && [selectedControl respondsToSelector:@selector(deleteChild:)]) {
        CCMatrix *parent = (CCMatrix *)selectedControl;
            // returns NO if any other children remain
        if (![parent deleteChild:sender]) {
            [self setSelection:selectedControl index:[parent currentIndex]];
            return;
        }
    }
    
    CCEModelledControl *model = [selectedControl modelledControl];
    
    if (model != nil) {
        [cardSettings removeObject:model];
    }
    
    [selectedControl removeFromSuperview];
    [controls removeObject:selectedControl];
    [self setSelection:nil];
    
        // force the modelled object out
    [[model managedObjectContext] deleteObject:model];
}

- (IBAction)setControlColorCode:(id)sender
{
    if (![sender respondsToSelector:@selector(selectedCell)]) {
        return;
    }
    NSInteger code = [[sender selectedCell] tag];
    
    NSColor *color = [(AppDelegate *)[NSApp delegate] colorForCode:code];
    if (color) {
        [controlColorWell setColor:color];
    } else {
        NSLog(@"No color for code %ld", code);
    }
}

- (void)selectControlObject:(CCEModelledControl *)object
{
    [self selectControlObject:object selIndex:0];
}

- (void)selectControlObject:(CCEModelledControl *)object selIndex:(NSInteger)index
{
        // make sure force-squaring does not affect newly set object
    self.square = [NSNumber numberWithBool:NO];
    selectedObject.content = nil;
    locationObject.content = nil;
    
    [selectedObject setContent:object];
    
    CCELocation *posObject = nil;
    if ([[object isIndexed] boolValue]) {
        CCEMultiCheckModel *indexedModel = (CCEMultiCheckModel *)object;
        posObject = [indexedModel locationWithIndex:index];
    } else {
        posObject = [object valueForKey:@"location"];
    }
    [locationObject setContent:posObject];
    
        // never force text objects to be squared
    BOOL canBeSquared = (object != nil && posObject != nil &&
                         ![[[object entity] name] isEqualToString:entityText]);
    self.canSquare = [NSNumber numberWithBool:canBeSquared];
    self.square = [NSNumber numberWithBool:canBeSquared &&
                   0 == fuzzyCompare([posObject.width doubleValue], [posObject.height doubleValue])];
    
    [infoPanel orderFront:self];
}

- (void)setSquare:(NSNumber *)value
{
    square = value;
    [self squareKeeper:self];
}

- (IBAction)squareKeeper:(id)sender
{
    if ([square boolValue]) {
        CCELocation *locObject = locationObject.content;
        double side = locObject.width.doubleValue;
        locObject.height = [NSNumber numberWithDouble:side];
    }
}

- (IBAction)updateUnits:(id)sender
{
        // Force the x, y, width, height fields to update when the preferred unit changes. Since
        // the actual value is the same (only the transformed value changes), NSTextField would
        // not update as expected.  Unbinding and rebinding the selected object location does the
        // trick, though.
    NSManagedObject *posObject = [locationObject content];
    [locationObject setContent:nil];
    [locationObject setContent:posObject];
}

#pragma mark CREATE CONTROLS

    // target of controls in layout mode
- (IBAction)layoutClick:(id)sender
{
    if (editMode) {
        NSInteger index = 0;
        
        if ([sender isKindOfClass:[NSButton class]]) {
            [sender setIntegerValue:0]; // always off
        } else if ([sender isKindOfClass:[CCMatrix class]]) {
            index = [sender integerValue];
            [sender setIntegerValue:0]; // always no selection
        }
            // TODO: preference for changing to kPointerControl
        if (controlType != kPointerControl)
            return;
        
        [self setSelection:sender index:index];
    }
}

- (void)targetSelf:(NSControl<CCDebuggableControl> *)control
{
    if (editMode) {
        [control setTarget:self];
        [control setAction:@selector(layoutClick:)];
    }
}

- (NSControl <CCDebuggableControl> *)controlFromModel:(CCEModelledControl *)model
{
    @try {
        NSControl <CCDebuggableControl> *newControl = nil;
        
        if ([entityCheckbox isEqualToString:[[model entity] name]]) {
            newControl = [self checkboxFromModel:model];
        } else if ([entityText isEqualToString:[[model entity] name]]) {
            newControl = [self textBoxFromModel:(CCETextModel *)model];
        } else if ([entityMultiCheck isEqualToString:[[model entity] name]]) {
            newControl = [self matrixFromModel:(CCEMultiCheckModel *)model];
        }
        
        if (!editMode) {
            CCEValueBinder *binding = [[CCEValueBinder alloc] initWithPartnership:partnership
                                                                          control:newControl];
            [bindings addObject:binding];
        }
        
        return newControl;
    }
    @catch (NSException *exception) {
        NSLog(@"%s line %d caught exception %@", __FILE__, __LINE__, exception);
    }
    
    return nil;
}

#pragma mark CHECKBOXES

- (NSPoint)checkBoxLowerLeft:(NSPoint)where
{
    NSPoint rawPoint = [view convertPoint:where fromView:nil];
    NSPoint vPoint = [NSView defaultUnscalePoint:rawPoint];
    
    loadDefaults();
    
        // center control on cursor
    vPoint.x -= localDflts.boxWidth / 2.0;
    vPoint.y -= localDflts.boxHeight / 2.0;

    vPoint = roundPt(vPoint);
    return vPoint;
}

- (CCCheckbox *)createCheckboxAt:(NSPoint)vPoint
{
    NSSize size = NSMakeSize(localDflts.boxWidth, localDflts.boxHeight);
    return [self createCheckboxAt:vPoint size:size];
}

- (CCCheckbox *)createCheckboxAt:(NSPoint)where size:(NSSize)size
{
    NSRect rect = {where, size};
    CCCheckbox *cbox = [[CCCheckbox alloc] initWithFrame:rect colorKey:ccNormalColor];
    [self visualSelect:cbox];
    return cbox;
}

- (void)createSingleCheckbox:(NSEvent *)theEvent
{
    NSPoint where = [self checkBoxLowerLeft:theEvent.locationInWindow];
    CCCheckbox *cbox = [self createCheckboxAt:where];
    [self targetSelf:cbox];
    [controls addObject:cbox];
    [view addSubview:cbox];
    
    CCESingleCheckModel *checkbox = [NSEntityDescription insertNewObjectForEntityForName:ccSingleCheck
                                                                  inManagedObjectContext:[controller managedObjectContext]];
    
    [cardSettings addObject:checkbox];
    
    [checkbox setDimX:[NSNumber numberWithDouble:localDflts.boxWidth]];
    [checkbox setDimY:[NSNumber numberWithDouble:localDflts.boxHeight]];
    
    [self createLocationFor:checkbox at:where];
    
    [cbox monitorModel:checkbox];
    
    [self setSelection:cbox];
}

- (CCCheckbox *)checkboxFromModel:(CCESingleCheckModel *)model
{
    CCCheckbox *cbox = [CCCheckbox checkboxWithCheckModel:model];
    
    if (editMode) {
        [self targetSelf:cbox];
        [cbox setDebugMode:kShowUnselected];
    }
    [controls addObject:cbox];
    [view addSubview:cbox];
    
    return cbox;
}

#pragma mark MULTI-CHECKBOXES

- (void)createMultiCheckbox:(NSEvent *)theEvent
{
    NSPoint where = [self checkBoxLowerLeft:theEvent.locationInWindow];
    NSSize size = NSMakeSize(localDflts.boxWidth, localDflts.boxHeight);
    NSRect theRect = {where, size};
    
        // create matrix coincident with view
    CCBoxMatrix *matrix = [[CCBoxMatrix alloc] initWithFrame:view.frame
                                                       rects:@[[NSValue valueWithRect:theRect]]
                                                      colors:@[ccNormalColor]
                                                        name:nil];
    [self targetSelf:matrix];
    [controls addObject:matrix];
    [view addSubview:matrix];
    
    CCEMultiCheckModel *model = [NSEntityDescription insertNewObjectForEntityForName:ccMultiCheck
                                                                   inManagedObjectContext:[controller managedObjectContext]];
    [cardSettings addObject:model];
    model.dimX = [NSNumber numberWithDouble:size.width];
    model.dimY = [NSNumber numberWithDouble:size.height];
    model.shape = [NSNumber numberWithInteger:kCheckboxes];
    
        // first checkbox in the control gets index 1, not 0; zero is reserved for "none selected"
    [self createLocationFor:model at:where withIndex:1];
    
    [matrix monitorModel:model index:1];
    [self setSelection:matrix index:1];
}

- (void)addBoxToMultiCheckbox:(NSEvent *)theEvent
{
    if (selectedControl == nil || ![selectedControl isKindOfClass:[CCBoxMatrix class]])
        [NSException raise:@"InvalidAddition"
                    format:@"%@ is the wrong type for adding a checkbox", [selectedControl class]];
    CCBoxMatrix *matrix = (CCBoxMatrix *)selectedControl;
    CCEMultiCheckModel *model = (CCEMultiCheckModel *)[matrix modelledControl];
    short prevIndex = [model.locations count];  // indices start at 1!
    short index = prevIndex + 1;
    
    NSPoint where = [self checkBoxLowerLeft:theEvent.locationInWindow];
    NSSize size = NSMakeSize(localDflts.boxWidth, localDflts.boxHeight);
    NSRect theRect = {where, size};
    
    [matrix placeChildInRect:theRect withColorCode:kNormalColor];
    
    CCELocation *locObj = [self createLocationFor:model withIndex:index];
    
    [matrix monitorModel:model index:index];

    CCELocation *prevLocation = [model locationWithIndex:prevIndex];
    NSNumber *colorCode = prevLocation.colorCode;
    if (colorCode == nil) {
        [locObj setColor:prevLocation.color];
    } else {
        [locObj setColorCode:colorCode];
    }
    
    [self setSelection:matrix index:index];
}

- (CCMatrix *)matrixFromModel:(CCEMultiCheckModel *)model
{
    CCMatrix *matrix;
    
    if (editMode) {
            // editing, so allow NEW child controls anywhere on screen
        
        matrix = [CCMatrix matrixFromModel:model insideRect:wholeFrame];
        [self targetSelf:matrix];
        [matrix monitorModel:model];
        [matrix setDebugMode:kShowUnselected];
    } else {
            // establish control rect from union of child rects
        matrix = [CCMatrix matrixFromModel:model];
    }
    
    [controls addObject:matrix];
    [view addSubview:matrix];
    
    return matrix;
}

#pragma mark LEAD CHOICE CIRCLES

- (void)createLeadCircle:(NSEvent *)theEvent
{
    NSPoint where = [self checkBoxLowerLeft:theEvent.locationInWindow];
    NSSize size = NSMakeSize(localDflts.ovalWidth, localDflts.ovalHeight);
    NSRect theRect = {where, size};
    
        // create matrix coincident with view
    CCLeadChoiceMatrix *matrix = [[CCLeadChoiceMatrix alloc] initWithFrame:view.frame
                                                                     rects:@[[NSValue valueWithRect:theRect]]
                                                                      name:nil];
    [self targetSelf:matrix];
    [controls addObject:matrix];
    [view addSubview:matrix];
    
    CCEMultiCheckModel *model = [NSEntityDescription insertNewObjectForEntityForName:ccMultiCheck
                                                              inManagedObjectContext:[controller managedObjectContext]];
    [cardSettings addObject:model];
    model.dimX = [NSNumber numberWithDouble:size.width];
    model.dimY = [NSNumber numberWithDouble:size.height];
    model.shape = [NSNumber numberWithInteger:kOvals];
    
        // first checkbox in the control gets index 1, not 0; zero is reserved for "none selected"
    CCELocation *loc = [self createLocationFor:model at:where withIndex:1];
    loc.colorCode = [NSNumber numberWithInteger:kNormalColor];
    
    [matrix monitorModel:model index:1];
    [self setSelection:matrix index:1];

}


- (void)addCircleToLeadCircles:(NSEvent *)theEvent
{
    if (selectedControl == nil || ![selectedControl isKindOfClass:[CCLeadChoiceMatrix class]])
        [NSException raise:@"InvalidAddition"
                    format:@"%@ is the wrong type for adding a circle", [selectedControl class]];
    CCLeadChoiceMatrix *matrix = (CCLeadChoiceMatrix *)selectedControl;
    CCEMultiCheckModel *model = (CCEMultiCheckModel *)[matrix modelledControl];
    short prevIndex = [model.locations count];  // indices start at 1!
    short index = prevIndex + 1;
    
    NSPoint where = [self checkBoxLowerLeft:theEvent.locationInWindow];
    NSSize size = NSMakeSize(localDflts.ovalWidth, localDflts.ovalHeight);
    NSRect theRect = {where, size};
    
    [matrix placeChildInRect:theRect withColorCode:kNormalColor];
    
    CCELocation *locObj = [self createLocationFor:model withIndex:index];
    
    [matrix monitorModel:model index:index];
    
    CCELocation *prevLocation = [model locationWithIndex:prevIndex];
    NSNumber *colorCode = prevLocation.colorCode;
    if (colorCode == nil) {
        [locObj setColor:prevLocation.color];
    } else {
        [locObj setColorCode:colorCode];
    }
    
    [self setSelection:matrix index:index];
}

    // add parts to controls
#pragma mark ADD PARTS

- (IBAction)addParts:(id)sender
{
    CCEModelledControl *selCtl = selectedObject.content;
    if (selCtl == nil)
        return;     // theoretically, can't happen (i.e., without programmer error)
    
    NSInteger selectionTag = 0;

        // control types
    if ([selCtl isKindOfClass:[CCEMultiCheckModel class]]) {
        CCEMultiCheckModel *ctl = (CCEMultiCheckModel *)selCtl;
        switch (ctl.shape.integerValue) {
            case kCheckboxes:
                selectionTag = kMultiCheckboxControl + kControlVariant;
                break;
                
            case kOvals:
                selectionTag = kCircleChoiceControl + kControlVariant;
                break;
        }
    }
    
    if (selectionTag != 0) {
        [window makeKeyAndOrderFront:self];
        [toolsPaletteController selectControlTagValue:selectionTag];
    }
}

#pragma mark TEXTBOXES

- (void)createTextControl:(NSEvent *)theEvent
{
    NSEvent *mouseDown = self.mouseDownEvent;
    self.mouseDownEvent = nil;
    
    NSPoint startPt = [view convertPoint:mouseDown.locationInWindow fromView:nil];
    NSPoint endPt = [view convertPoint:theEvent.locationInWindow fromView:nil];
    NSRect rawRect = JFH_RectFromPoints(startPt, endPt);
    
    NSRect rect = roundedRect([NSView defaultUnscaleRect:rawRect]);
    
    CCETextModel *model = [NSEntityDescription insertNewObjectForEntityForName:ccText
                                                        inManagedObjectContext:[controller managedObjectContext]];
    [cardSettings addObject:model];
    [self createLocationFor:model at:rect.origin withSize:rect.size];
    CCESizableTextField *textField = [[CCESizableTextField alloc] initWithLocation:model.location
                                                                          isNumber:NO
                                                                         colorCode:kNormalColor];
    [self targetSelf:textField];
    [controls addObject:textField];
    [view addSubview:textField];
    
    [textField monitorModel:model];
    
    [self setSelection:textField];
}

- (id)textBoxFromModel:(CCETextModel *)model
{
    id textField;
    
    if (editMode) {
        textField = [CCESizableTextField textFieldFromModel:model];
        [self targetSelf:textField];
        [textField setDebugMode:kShowUnselected];
    } else {
        textField = [CCTextField textFieldFromModel:model];
    }
    
    [controls addObject:textField];
    [view addSubview:textField];
    
    return textField;
}

#pragma mark DUPLICATION

- (IBAction)duplicateControl:(id)sender
{
    CCEModelledControl *oldModel = selectedControl.modelledControl;
    CCEModelledControl *model;
    CCEDuplicator *duplicator = [CCEDuplicator instance];
    
    if (duplicatingObjectsState) {
        model = (CCEModelledControl *)[duplicator cloneModel:oldModel
                                                                  offsetBy:duplicatingDiffLocation];
    } else {
        model = (CCEModelledControl *)[duplicator cloneModel:oldModel];
    }
    NSControl <CCDebuggableControl> *newCtl = [self controlFromModel:model];
    [self setSelection:newCtl];
    
    if (!duplicatingObjectsState) {
        [duplicator askConfirm:model from:oldModel forController:self];
    }
    
    duplicatingObjectsState = YES;
    duplicatingDiffLocation = [CCEDuplicator locationDiff:model.location from:oldModel.location];
    
}

#pragma mark LOCATIONS

- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
{
    return [self createLocationFor:ctl withIndex:0];
}
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where
{
    return [self createLocationFor:ctl at:where withIndex:0];
}
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl withIndex:(NSUInteger)index
{
    NSView *theControl = selectedControl;
        // locations must account for zooming, too
    NSPoint realRawPt;
    if (index > 0 && [theControl conformsToProtocol:@protocol(CCctrlParent)]) {
        NSView *innerControl = [(id<CCctrlParent>)theControl childWith1Index:index];
        realRawPt = [view convertPoint:[innerControl frame].origin fromView:selectedControl];
    } else {
        realRawPt = [view convertPoint:[theControl frame].origin fromView:view];
    }
    NSPoint realPt = [NSView defaultUnscalePoint:realRawPt];
    
    return [self createLocationFor:ctl at:realPt withIndex:index];
}
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
                       at:(NSPoint)where
                withIndex:(NSUInteger)index
{
    NSSize size = NSMakeSize([[ctl dimX] doubleValue], [[ctl dimY] doubleValue]);
    return [self createLocationFor:ctl at:where withIndex:index withSize:size];
}
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where withSize:(NSSize)size
{
    return [self createLocationFor:ctl at:where withIndex:0 withSize:size];
}
- (CCELocation *)createLocationFor:(CCEModelledControl *)ctl
                       at:(NSPoint)where
                withIndex:(NSUInteger)index
                 withSize:(NSSize)size
{
    CCELocation *locObj = [NSEntityDescription insertNewObjectForEntityForName:ccLocation
                                                        inManagedObjectContext:[controller managedObjectContext]];
    [locObj setWidth:[NSNumber numberWithDouble:size.width]];
    [locObj setHeight:[NSNumber numberWithDouble:size.height]];
    
    [locObj setLocX:[NSNumber numberWithDouble:where.x]];
    [locObj setLocY:[NSNumber numberWithDouble:where.y]];
    
    [locObj setIndex:[NSNumber numberWithShort:index]];
    
    [ctl setLocation:locObj];
    return locObj;
}

- (void)stopMonitoringLocations
{
    [controls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(stopMonitoring)]) {
            [obj stopMonitoring];
        }
    }];
}

#pragma mark SCALING

- (IBAction)absoluteScale:(id)sender
{
    double newScale;
    if ([sender isKindOfClass:[NSControl class]]) {
        NSControl *slider = (NSControl *)sender;
        newScale = [slider doubleValue];
    } else if ([sender isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)sender;
        newScale = [num doubleValue];
    } else {
        [NSException raise:@"UnrecognizedIdType"
                    format:@"sender (%@) is neither a NSControl nor NSNumber", sender];
    }
    
    [self rescale:newScale];
}

- (IBAction)scaleZero:(id)sender
{
    [cardImageView zoomImageToActualSize:sender];
}

- (IBAction)scaleLarger:(id)sender
{
    [cardImageView zoomIn:sender];
}

- (IBAction)scaleSmaller:(id)sender
{
    [cardImageView zoomOut:sender];
}

- (IBAction)scaleToWindow:(id)sender
{
    [cardImageView fill];
}

- (void)rescale:(double)newScale
{
    [cardImageView setZoomFactor:newScale];
}

    // forward image information
- (void)setImageWithURL:(NSURL *)url
{
    [cardImageView setImageWithURL:url];
}

- (NSSize)imageSize
{
    return [cardImageView imageSize];
}

#pragma mark INFO PANEL

- (void)resignFront
{
    [infoPanel orderOut:self];
    [toolsPaletteController hide];
}

- (IBAction)controlInfo:(id)sender
{
    if ([infoPanel isVisible]) {
        [infoPanel orderOut:sender];
    } else {
        [infoPanel orderFront:sender];
    }
}

    // enable the "controls visible" mode when template window (or infoPanel) is key
- (void)windowDidBecomeKey:(NSNotification *)notification
{
    NSWindow *keyWindow = (NSWindow *)[notification object];
    if (keyWindow == window || keyWindow == infoPanel) {
        [CCDebuggableControlEnable setEnabled:YES];
    }
    
    [controller activateEditorWindow:self];
}

- (IBAction)editControlName:(id)sender
{
    [infoPanel makeKeyAndOrderFront:sender];
    [infoPanel makeFirstResponder:nameField];
}

- (IBAction)editControlPosition:(id)sender
{
    [infoPanel makeKeyAndOrderFront:sender];
    [infoPanel makeFirstResponder:xField];
}

- (IBAction)editControlColor:(id)sender
{
    [infoPanel makeKeyAndOrderFront:sender];
    [infoPanel makeFirstResponder:controlColorWell];
}

- (IBAction)numericSetting:(id)sender
{
    NSInteger value = -1;
    if ([sender respondsToSelector:@selector(integerValue)]) {
        value = [sender integerValue];
    }
    if (value < 0) {
        return;
    }
    
    if ([selectedControl respondsToSelector:@selector(setNumberField:)]) {
        [(id)selectedControl setNumberField:value];
    }
}

#pragma mark FINDING CONTROL OBJECTS

    // find the control model representing the control view
- (CCEModelledControl *)modelledControlFor:(NSControl<CCDebuggableControl> *)ctl
{
    if (ctl == nil) {
        return nil;
    }
    CCEModelledControl *control = ctl.modelledControl;
    if (control != nil) {
        return control;
    }
    NSRect rect = [view convertRect:[ctl bounds] fromView:ctl];
    control = [[CCEEntityFetcher instance] modelledControlAt:rect.origin];
    
    return control;
}

#pragma mark TEST CONTROLS

- (IBAction)testControl:(id)sender
{
    NSControl <CCDebuggableControl> *control = selectedControl;
    if (selectedControl == nil) {
        NSLog(@"ERROR: no control selected");
        return;
    }
    
    [CCEControlTest newTesterForControl:control notify:self];
}

- (CCEControlTest *)testerForSelected
{
    return [CCEControlTest testerForControl:selectedControl];
}

- (IBAction)cancelTestControl:(id)sender
{
    NSControl <CCDebuggableControl> *control = selectedControl;
    if (control == nil) {
        return;
    }
    
    CCEControlTest *tester = [CCEControlTest testerForControl:control];
    if (tester) {
        [tester cancel];
    }
}

- (void)flashControlTester:(CCEControlTest *)tester
{
    BOOL testerForSelected = tester != nil && tester.isRunning;
    self.isTesterForSelected = [NSNumber numberWithBool:testerForSelected];
    if (!testerForSelected) {
        [selectedControl setDebugMode:kShowSelected];
    }
}

- (IBAction)stopAllControlTesters:(id)sender
{
    [CCEControlTest stopAllTestersInWindow:window];
}

#pragma mark VALIDATION

- (BOOL)validateUserInterfaceItem:(NSObject <NSValidatedUserInterfaceItem> *)anItem
{
    SEL action = anItem.action;
    if (action == @selector(testControl:)) {
        return ![testControlButton isHidden] && [testControlButton isEnabled];
    } else if (action == @selector(cancelTestControl:)) {
        return ![stopTestControlButton isHidden];
    } else if (action == @selector(stopAllControlTesters:)) {
        return [CCEControlTest testerCount] > 0;
    } else if (action == @selector(scaleLarger:)) {
        return [cardImageView canZoomIn];
    } else if (action == @selector(scaleSmaller:)) {
        return [cardImageView canZoomOut];
    } else if (action == @selector(showSelectedControlInfo:)) {
        id obj = [selectedObject content];
        return editMode && obj != nil;
    } else if (action == @selector(controlInfo:)) {
        return editMode;
    } else if (action == @selector(toggleGridState:)) {
        if ([anItem isKindOfClass:[NSMenuItem class]]) {
            NSMenuItem *menuItem = (NSMenuItem *)anItem;
            [menuItem setState:gridState ? NSOnState : NSOffState];
        }
        return editMode;
    } else if (action == @selector(editControlColor:) ||
               action == @selector(editControlName:) ||
               action == @selector(editControlPosition:)) {
        return editMode && selectedControl != nil;
    } else if (action == @selector(chooseControlByTag:)) {
        if (!editMode) {
            return NO;
        }
        CCEModelledControl *selectedCtl = selectedObject.content;
        NSInteger tag = [anItem tag];
        switch (tag) {
            case kMultiCheckboxControl + kControlVariant:
            case kCircleChoiceControl + kControlVariant:
            {
                BOOL okType = selectedCtl != nil && [selectedCtl isKindOfClass:[CCEMultiCheckModel class]];
                if (!okType)
                    return NO;
                
                CCEMultiCheckModel *ctl = (CCEMultiCheckModel *)selectedCtl;
                switch (ctl.shape.integerValue) {
                    case kCheckboxes:
                        return tag == kMultiCheckboxControl + kControlVariant;
                        break;
                        
                    case kOvals:
                        return tag == kCircleChoiceControl + kControlVariant;
                        break;
                        
                    default:
                        return NO;
                }
            }
                
            default:
                return YES;
        }
    } else if (action == @selector(duplicateControl:)) {
        return selectedControl /*&& [selectedControl.modelledControl.entity.name isEqualToString:entityText]*/;
    }

    
    return YES;
}

- (IBAction)toggleGridState:(id)sender
{
    self.gridState = !gridState;
}

- (void)setGridState:(BOOL)state
{
    gridState = state;
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:cceGridState];
    self.gridStateLabel = state ? hideGrid : showGrid;
    [view setGridState:state];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    SEL action = theItem.action;
    if (action == @selector(toggleGridState:)) {
        [theItem setLabel:gridStateLabel];
        return editMode;
    } else if (action == @selector(controlInfo:)) {
        return editMode;
    }
    return cardType != nil;
}

- (void)errorDisplay:(NSNotification *)notify
{
    NSWindow *displayIn = window;
    
    if ([infoPanel isKeyWindow]) {
        displayIn = infoPanel;
    }
    
    NSDictionary *eDict = notify.userInfo;
    NSError *error = [eDict valueForKey:errorNotify];
    
    NSBeginCriticalAlertSheet(error.localizedDescription,
                              NSLocalizedString(@"OK", @"OK string"),
                              nil,
                              nil,
                              displayIn,
                              self,
                              @selector(sheetEnded:returnCode:contextInfo:),
                              nil,
                              NULL,
                              error.localizedFailureReason);
}

- (void)sheetEnded:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
        // just to refresh the text fields bound to the content...
    id content = locationObject.content;
    [locationObject setContent:nil];
    [locationObject setContent:content];
}

#pragma mark WINDOW DELEGATE

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    if (editMode ) {
        [toolsPaletteController.toolsPalette orderFront:self];
    } else {
        [toolsPaletteController hide];
    }
    [controller activateEditorWindow:self];
}

- (BOOL)windowShouldClose:(id)sender {
    if (sender == window) {
//        [sender orderOut:self];
        [self stopMonitoringLocations];
        
        [self infoPanelUninit];
        [infoPanel setReleasedWhenClosed:YES];
        [infoPanel close];
        [toolsPaletteController.toolsPalette close];
        [controller editorWindowClosing:self];
        [self stopAllControlTesters:sender];
        
            // stop steppers from observing
        [xPosStepper observeIncrementFrom:nil keypath:cceStepIncrement];
        [yPosStepper observeIncrementFrom:nil keypath:cceStepIncrement];
        [widthStepper observeIncrementFrom:nil keypath:cceStepIncrement];
        [heightStepper observeIncrementFrom:nil keypath:cceStepIncrement];
        
            // stop observing things myself
        [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:cceStepIncrement];
        [self unobserveDefaults];
        
        bindings = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSWindow* theWin = [notification object];
    [theWin setDelegate:nil];
}

#pragma mark WINDOW_INITIALIZATION

- (void)infoPanelInit
{
        // standard colors for controls
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for (int index = kStandardColorsLowerBound; index < kNumberStandardColors; ++index) {
        CCEColorBindableButtonCell *cell = [stdControlColorGroup cellWithTag:index];
        
        if (cell == nil)
            continue;
        if (![cell isKindOfClass:[CCEColorBindableButtonCell class]])
            continue;
        
        [cell observeTextColorFrom:ud keypath:[CommonStrings standardColorKey:index]];
    }
}

- (void)infoPanelUninit
{
    for (int index = kStandardColorsLowerBound; index < kNumberStandardColors; ++index) {
        CCEColorBindableButtonCell *cell = [stdControlColorGroup cellWithTag:index];
        
        if (cell == nil)
            continue;
        if (![cell isKindOfClass:[CCEColorBindableButtonCell class]])
            continue;
        
        [cell observeTextColorFrom:nil keypath:nil];
    }
}

#pragma mark UNDO MANAGEMENT

- (NSUndoManager *)undoManager
{
    return [[controller managedObjectContext] undoManager];
}

- (IBAction)undo:(id)sender
{
    [[controller managedObjectContext] undo];
}

- (IBAction)redo:(id)sender
{
    [[controller managedObjectContext] redo];
}

#pragma mark DEBUGGING

- (IBAction)showSelectedControlInfo:(id)sender
{
    CCEModelledControl *ctl = [selectedObject content];
    if (ctl == nil) {
        NSLog(@"No control is selected--abort");
        return;
    }
    
    NSRect frame, bounds;
    
    NSControl *selected = [self selectedControl];
    frame = [selected frame];
    bounds = [selected bounds];
    
    NSLog(@"In itself: frame:%@ bounds:%@", NSStringFromRect(frame), NSStringFromRect(bounds));
    
        // in view
    [view convertRect:frame fromView:selected];
    [view convertRect:bounds fromView:selected];
    
    NSLog(@"In view: frame:%@ bounds:%@", NSStringFromRect(frame), NSStringFromRect(bounds));
    
        // in window
    [view convertRect:frame toView:nil];
    [view convertRect:bounds toView:nil];
    
    NSLog(@"In window: frame:%@ bounds:%@", NSStringFromRect(frame), NSStringFromRect(bounds));
    
    NSLog(@"un-nest view frames:");
    
    for (NSView *aview = selected; aview != nil; aview = [aview superview]) {
        NSLog(@"view %@ (%p): frame %@", NSStringFromClass([aview class]), aview,
              NSStringFromRect([aview frame]));
    }
    
    NSLog(@"sub views (frame inside view):");
    
    [[selected subviews] enumerateObjectsUsingBlock:^(NSView *aview, NSUInteger idx, BOOL *stop) {
        NSLog(@"view %@ (%p): frame %@", NSStringFromClass([aview class]), aview,
              NSStringFromRect([aview convertRect:[aview frame] toView:selected]));
    }];
}

- (IBAction)showResponderChain:(id)sender
{
    NSResponder *firstResponder = window.firstResponder;
    
    while (firstResponder != nil) {
        NSString *title = nil;
        NSString *value = nil;
        
        if ([firstResponder isKindOfClass:CCEModelledControl.class]) {
            title = [(CCEModelledControl *)firstResponder name];
        } else if ([firstResponder respondsToSelector:@selector(title)])
            title = [(id)firstResponder title];
        if ([firstResponder respondsToSelector:@selector(stringValue)])
            value = [(id)firstResponder stringValue];
        NSLog(@"NSResponder: %@ (%p) %@  %@", firstResponder.class, firstResponder, title, value);
        firstResponder = firstResponder.nextResponder;
    }
}

+ (NSInteger)count
{
    return s_count;
}

@end
