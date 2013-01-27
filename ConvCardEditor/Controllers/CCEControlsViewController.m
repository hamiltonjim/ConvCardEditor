//
//  CCEControlsView.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/14/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "NSView+ScaleUtilities.h"
#import "CCEControlsViewController.h"
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
#import "CCECardTypeEditorController.h"
#import "CCEEntityFetcher.h"
#import "NSView+ScaleUtilities.h"
#import "CCESizableTextField.h"
#import "CCETextModel.h"

#import "math.h"

@interface CCEControlsViewController ()

@property (weak, readwrite, nonatomic) NSControl <CCDebuggableControl> *selectedControl;
@property (nonatomic) NSMutableSet *cardSettings;
@property (nonatomic) double zoom;

@property NSEvent *mouseDownEvent;

- (void)observeDefaults:(NSArray *)defaultsList;

- (void)visualSelect:(NSControl<CCDebuggableControl> *)aControl;
- (void)targetSelf:(NSControl <CCDebuggableControl> *)control;

- (NSPoint)checkBoxLowerLeft:(NSPoint)where;
- (CCCheckbox *)createCheckboxAt:(NSPoint)where;
- (CCCheckbox *)createCheckboxAt:(NSPoint)where size:(NSSize)size;
- (void)createSingleCheckbox:(NSEvent *)theEvent;

- (void)createTextControl:(NSEvent *)theEvent;

- (void)createLocationFor:(CCEModelledControl *)ctl;
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where;
- (void)createLocationFor:(CCEModelledControl *)ctl withIndex:(short)index;
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where withIndex:(short)index;
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where withSize:(NSSize)size;
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where withIndex:(short)index withSize:(NSSize)size;

- (CCEModelledControl *)modelledControlFor:(NSControl <CCDebuggableControl> *)ctl;

- (NSPoint)zoomPoint:(NSPoint)pt;
- (NSPoint)unzoomPoint:(NSPoint)pt;

- (void)placeView:(id <CCDebuggableControl>)view;

- (NSControl <CCDebuggableControl> *)controlFromModel:(CCEModelledControl *)model;
- (CCCheckbox *)checkboxFromModel:(CCEModelledControl *)model;
- (CCBoxMatrix *)boxMatrixFromModel:(CCEModelledControl *)model;
- (CCLeadChoiceMatrix *)ovalMatrixFromModel:(CCEModelledControl *)model;
- (id)textBoxFromModel:(CCEModelledControl *)model;

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

@synthesize view;
@synthesize cardType;
@synthesize cardSettings;
@synthesize zoom;

@synthesize observedView;
@synthesize controls;
@synthesize selectedControl;
@synthesize controlType;

@synthesize editMode;

@synthesize controller;

@synthesize mouseDownEvent;


    // start observing a list of preferences
- (void)observeDefaults:(NSArray *)defaultsList
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [defaultsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ud addObserver:self
             forKeyPath:obj
                options:NSKeyValueObservingOptionInitial
                context:nil];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:ccDimensionUnit]) {
        [view setNeedsDisplay:YES];
    } else {
            // catch-all is for control sizes
        localDflts.defaultsValid = false;
    }
}

- (void)awakeFromNib
{
        // resizing handled manually
    [view setAutoresizesSubviews:NO];
    
    NSArray *dfltsList = @[ccDimensionUnit,
        ccChecksAreSquare, ccCheckboxWidth, ccCheckboxHeight,
        ccCirclesAreRound, ccCircleWidth, ccCircleHeight];
    [self observeDefaults:dfltsList];
}

- (void)viewMouseUp:(NSEvent *)theEvent
{
    switch (controlType) {
        case kPointerControl:
            [self setSelection:nil];
            break;
            
        case kSingleCheckboxControl:
            [self createSingleCheckbox:theEvent];
            break;
            
        case kTextControl:
            [self createTextControl:theEvent];
            break;
        
        default:
            NSLog(@"Handler for type %ld not implemented", controlType);
            break;
    }
    
    [controller chooseNextControl];
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

- (void)visualSelect:(NSControl<CCDebuggableControl> *)aControl
{
    [selectedControl setDebugMode:kShowUnselected];
    self.selectedControl = aControl;
    [selectedControl setDebugMode:kShowSelected];
}

- (void)load:(NSManagedObject *)type
{
    [self load:type editMode:NO];
}
- (void)load:(NSManagedObject *)type editMode:(BOOL)editing
{
    self.editMode = editing;
    self.cardType = type;
    self.cardSettings = [type mutableSetValueForKey:@"settings"];
    
    NSUInteger size = 100;
    NSUInteger numCtls = [[type settings] count];
    if (numCtls > size) size = numCtls;
    controls = [NSMutableArray arrayWithCapacity:size];
    
        // load existing controls
    [cardSettings enumerateObjectsUsingBlock:^(CCEModelledControl *obj, BOOL *stop) {
        [self controlFromModel:obj];
    }];
}

- (void)setSelection:(NSControl<CCDebuggableControl> *)aControl
{
    if (!editMode)
        return;
    
    self.mouseDownEvent = nil;
    
    [self visualSelect:aControl];
    self.selectedControl = aControl;
    [controller selectControlObject:[self modelledControlFor:aControl]];
}

- (IBAction)deleteSelected:(id)sender
{
    self.mouseDownEvent = nil;
    
    if (selectedControl == nil) {
        return;
    }
        // if the control is part of a matrix, delete it from the matrix
    if ([selectedControl respondsToSelector:@selector(parent)]) {
        CCMatrix *parent = (CCMatrix *)[selectedControl performSelector:@selector(parent)];
        if (parent != nil) {
            [parent deleteChild:sender];
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

- (void)setGridState:(BOOL)state
{
    [view setGridState:state];
}

#pragma mark CREATE_CONTROLS

    // target of controls in layout mode
- (IBAction)layoutClick:(id)sender
{
    if (editMode) {
        [sender setIntegerValue:0]; // always off
        if (controlType != kPointerControl)
            return;
        
        [self setSelection:sender];
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
    NSControl <CCDebuggableControl> *newControl = nil;
    
    if ([entityCheckbox isEqualToString:[[model entity] name]]) {
        newControl = [self checkboxFromModel:model];
    }
    
    return newControl;
}

#pragma mark CHECKBOXES

- (NSPoint)checkBoxLowerLeft:(NSPoint)where
{
    NSPoint vPoint = [view convertPoint:where fromView:nil];
    
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
    
    [checkbox setControlInView:cbox];
    [cbox setModelledControl:checkbox];
    
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

#pragma mark TEXTBOXES

- (void)createTextControl:(NSEvent *)theEvent
{
    NSEvent *mouseDown = self.mouseDownEvent;
    self.mouseDownEvent = nil;
    
    NSPoint startPt = [view convertPoint:mouseDown.locationInWindow fromView:nil];
    NSPoint endPt = [view convertPoint:theEvent.locationInWindow fromView:nil];
    NSRect rect = roundedRect(JFH_RectFromPoints(startPt, endPt));
    
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
    
    [model setControlInView:textField];
    [textField setModelledControl:model];
    
    [self setSelection:textField];
}

#pragma mark LOCATIONS

- (void)createLocationFor:(CCEModelledControl *)ctl
{
    [self createLocationFor:ctl withIndex:0];
}
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where
{
    [self createLocationFor:ctl at:where withIndex:0];
}
- (void)createLocationFor:(CCEModelledControl *)ctl withIndex:(short)index
{
    NSView *theControl = [ctl controlInView];
        // locations must account for zooming, too
    NSPoint realPt = [view convertPoint:[theControl frame].origin fromView:view];
    
    [self createLocationFor:ctl at:realPt withIndex:index];
}
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where withIndex:(short)index
{
    NSSize size = NSMakeSize([[ctl dimX] doubleValue], [[ctl dimY] doubleValue]);
    [self createLocationFor:ctl at:where withIndex:index withSize:size];
}
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where withSize:(NSSize)size
{
    [self createLocationFor:ctl at:where withIndex:0 withSize:size];
}
- (void)createLocationFor:(CCEModelledControl *)ctl at:(NSPoint)where withIndex:(short)index withSize:(NSSize)size
{
    CCELocation *locObj = [NSEntityDescription insertNewObjectForEntityForName:ccLocation
                                                        inManagedObjectContext:[controller managedObjectContext]];
    [locObj setWidth:[NSNumber numberWithDouble:size.width]];
    [locObj setHeight:[NSNumber numberWithDouble:size.height]];
    
    [locObj setLocX:[NSNumber numberWithDouble:where.x]];
    [locObj setLocY:[NSNumber numberWithDouble:where.y]];
    
    [locObj setIndex:[NSNumber numberWithShort:index]];
    
    [ctl setLocation:locObj];
}

#pragma mark FINDING_CONTROL_OBJECTS

    // find the control model representing the control view
- (CCEModelledControl *)modelledControlFor:(NSControl<CCDebuggableControl> *)ctl
{
    if (ctl == nil) {
        return nil;
    }
    NSRect rect = [view convertRect:[ctl bounds] fromView:ctl];
    CCEModelledControl *control = [[CCEEntityFetcher instance] modelledControlAt:rect.origin];
    if (control == nil) {
            // kluge: find it the old-fashioned way
        NSArray *ctls = [[CCEEntityFetcher instance] allModelledControls];
        
        __block CCEModelledControl *found = nil;
        [ctls enumerateObjectsUsingBlock:^(CCEModelledControl *obj, NSUInteger idx, BOOL *stop) {
            if ([obj controlInView] == ctl) {
                found = obj;
                *stop = YES;
            }
        }];
        control = found;
    }
    
    return control;
}

#pragma mark SCALING

- (NSPoint)zoomPoint:(NSPoint)pt
{
    pt.x *= zoom;
    pt.y *= zoom;
    
    return pt;
}

- (NSPoint)unzoomPoint:(NSPoint)pt
{
    pt.x /= zoom;
    pt.y /= zoom;
    
    return pt;
}

@end
