//
//  CCEDuplicator.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEDuplicator.h"
#import "CCEDuplicateNamer.h"
#import "CCEModelledControl.h"
#import "CCEManagedObjectModels.h"
#import "CCEControlsViewController.h"

#import "CCETextModel.h"
#import "CCESingleCheckModel.h"
#import "CCEMultiCheckModel.h"
#import "CCELocation.h"

#import "CCDebuggableControl.h"

#import "AppDelegate.h"
#import "CommonStrings.h"
#import "fuzzyMath.h"

static const CGFloat stdOffsetBy = 5.0;
static CCEDuplicator *theInstance = nil;

static NSString *leftStr;
static NSString *rightStr;
static NSString *upStr;
static NSString *downStr;

@interface CCEDuplicator ()

@property IBOutlet NSPanel *panel;

@property (weak) IBOutlet NSTextField *leftRight;
@property (weak) IBOutlet NSTextField *updown;

@property (weak) IBOutlet NSTextField *deltaX;
@property (weak) IBOutlet NSTextField *deltaY;

@property (weak) IBOutlet NSTextField *absX;
@property (weak) IBOutlet NSTextField *absY;

@property (weak) IBOutlet NSObjectController *location1;
@property (weak) IBOutlet NSObjectController *selfProxy;

@property (weak) IBOutlet NSSegmentedControl *xMover;
@property (weak) IBOutlet NSSegmentedControl *yMover;

@property (nonatomic) NSNumber *numDeltaX;
@property (nonatomic) NSNumber *numDeltaY;

@property (readwrite) NSString *relX;
@property (readwrite) NSString *relY;

@property CCEModelledControl *originalModel;
@property CCEModelledControl *consideredModel;
@property CCEControlsViewController *controller;

@property NSControl <CCDebuggableControl> *actualControl;

@property NSArray *topObjects;

@property BOOL changeInProgress;

@property CGFloat stepIncrementPref;

- (id)newEntityModel:(NSManagedObject *)original;

- (CCETextModel *)cloneText:(NSManagedObject *)original offsetBy:(NSSize)offset;
- (CCEMultiCheckModel *)cloneMultiCheck:(NSManagedObject *)original offsetBy:(NSSize)offset;
- (CCESingleCheckModel *)cloneSingleCheck:(NSManagedObject *)original offsetBy:(NSSize)offset;
- (CCELocation *)cloneLocation:(NSManagedObject *)original offsetBy:(NSSize)offset;

- (void)addClone:(CCEModelledControl *)newModel toCardType:(NSManagedObject *)cardType;

- (NSString *)leftOrRight:(CGFloat)dX;
- (NSString *)upOrDown:(CGFloat)dY;

- (NSSize)suggestOffset:(NSSet *)locations;
- (void)makeRelativeOffset;
- (void)doRelStrings;

@end

@implementation CCEDuplicator

@synthesize panel;

@synthesize leftRight;
@synthesize updown;

@synthesize deltaX;
@synthesize deltaY;

@synthesize absX;
@synthesize absY;

@synthesize numDeltaX;
@synthesize numDeltaY;

@synthesize originalModel;
@synthesize consideredModel;
@synthesize controller;

@synthesize actualControl;

@synthesize location1;

@synthesize topObjects;

@synthesize changeInProgress;

@synthesize stepIncrementPref;

+ (CCEDuplicator *)instance
{
    @synchronized(self) {
        if (theInstance == nil) {
            theInstance = [self new];
        }
    }
    
    return theInstance;
}

+ (NSSize)locationDiff:(CCELocation *)newLocation from:(CCELocation *)oldlocation
{
    if (![newLocation.entity.name isEqualToString:entityLocation] ||
        ![oldlocation.entity.name isEqualToString:entityLocation]) {
        [NSException raise:@"InvalidManagedObjects"
                    format:@"Both managed objects must be Locations: %@ vs %@",
         newLocation, oldlocation];
    }
    
    return NSMakeSize(newLocation.locX.doubleValue - oldlocation.locX.doubleValue,
                      newLocation.locY.doubleValue - oldlocation.locY.doubleValue);
}

- (id)init
{
    if (self = [super init]) {
        changeInProgress = NO;
    }
    return self;
}

- (id)cloneModel:(NSManagedObject *)original
{
        // place new object down and to right by std amount
    return [self cloneModel:original offsetBy:NSMakeSize(0, 0)];
}

- (NSManagedObject *)cloneModel:(NSManagedObject *)original offsetBy:(NSSize)offset
{
    CCEModelledControl *newModel;
    if ([original.entity.name isEqualToString:entityLocation]) {
            // not a CCEModelledControl; just return clone
        return [self cloneLocation:original offsetBy:offset];
    } else if ([original.entity.name isEqualToString:entityText]) {
        newModel = [self cloneText:original offsetBy:offset];
    } else if ([original.entity.name isEqualToString:entityMultiCheck]) {
        newModel = [self cloneMultiCheck:original offsetBy:offset];
    } else if ([original.entity.name isEqualToString:entityCheckbox]) {
        newModel = [self cloneSingleCheck:original offsetBy:offset];
    } else {
    
        // if we get here, something is badly wrong...
    [NSException raise:@"UnknownModelType"
                format:@"Attempt to clone unknown model of type %@", original.entity.name];
        // make the "no return" warning go away...
    return nil;
    }
    
        // add the clone to the card type model
    [self addClone:newModel toCardType:original.cardType];
    
    return newModel;
}

- (NSManagedObject *)newEntityModel:(NSManagedObject *)original
{
    return [NSEntityDescription insertNewObjectForEntityForName:original.entity.name
                                         inManagedObjectContext:original.managedObjectContext];
}

- (void)addClone:(CCEModelledControl *)newModel toCardType:(NSManagedObject *)cardType
{
    NSMutableSet *settings = [cardType mutableSetValueForKey:@"settings"];
    [settings addObject:newModel];
}

- (CCETextModel *)cloneText:(CCETextModel *)original offsetBy:(NSSize)offset
{
    CCETextModel *model = [self newEntityModel:original];
    
    model.name = [[CCEDuplicateNamer instance] nameForDuplicateOfName:original.name];
    model.fontSize = original.fontSize;
    model.lines = original.lines;
    model.numeric = original.numeric;
    
    model.location = [self cloneLocation:original.location offsetBy:offset];
    
    return model;
}

- (CCELocation *)cloneLocation:(CCELocation *)original offsetBy:(NSSize)offset
{
    if (offset.width == 0 && offset.height == 0) {
            //generic default
        offset = NSMakeSize(stdOffsetBy, -stdOffsetBy);
    }
    
    CCELocation *model = [self newEntityModel:original];
    
    model.colorAlpha = original.colorAlpha;
    model.colorRed = original.colorRed;
    model.colorGreen = original.colorGreen;
    model.colorBlue = original.colorBlue;
    model.colorCode = original.colorCode;
    model.height = original.height;
    model.width = original.width;
    model.index = original.index;
    
    model.locX = [NSNumber numberWithDouble:(original.locX.doubleValue + offset.width)];
    model.locY = [NSNumber numberWithDouble:(original.locY.doubleValue + offset.height)];
    
    return model;
}

- (CCESingleCheckModel *)cloneSingleCheck:(CCESingleCheckModel *)original offsetBy:(NSSize)offset
{
    if (NSEqualSizes(offset, NSMakeSize(0.0, 0.0))) {
        offset = NSMakeSize(stdOffsetBy, -stdOffsetBy);
    }

    CCESingleCheckModel *model = [self newEntityModel:original];
    
    model.name = [[CCEDuplicateNamer instance] nameForDuplicateOfName:original.name];
    model.dimX = original.dimX;
    model.dimY = original.dimY;
    
    model.location = [self cloneLocation:original.location offsetBy:offset];
    
    return model;
}

- (CCEMultiCheckModel *)cloneMultiCheck:(CCEMultiCheckModel *)original offsetBy:(NSSize)offset
{
    if (NSEqualSizes(offset, NSMakeSize(0.0, 0.0))) {
        offset = [self suggestOffset:original.locations];
    }
    
    CCEMultiCheckModel *model = [self newEntityModel:original];
    
    model.name = [[CCEDuplicateNamer instance] nameForDuplicateOfName:original.name];

    model.dimX = original.dimX;
    model.dimY = original.dimY;
    model.shape = original.shape;
    
    NSMutableSet *newlocs = [model mutableSetValueForKey:@"locations"];
    for (CCELocation* loc in original.locations) {
        [newlocs addObject:[self cloneLocation:loc offsetBy:offset]];
    }
    [model validateParts];
    
    return model;
}

- (NSSize)suggestOffset:(NSSet *)locations
{
    NSUInteger ct = locations.count;
    NSMutableSet *theExes = [NSMutableSet setWithCapacity:ct];
    NSMutableSet *theWyes = [NSMutableSet setWithCapacity:ct];
    CCELocation *firstLoc;
    NSUInteger lowIndex = ~0;   // all 1's or max value of an unsigned
    
    for (CCELocation *loc in locations) {
        [theExes addObject:loc.locX];
        [theWyes addObject:loc.locY];
        
        if (loc.index.integerValue < lowIndex) {
            lowIndex = loc.index.integerValue;
            firstLoc = loc;
        }
    }

    NSSize suggestion;
        // if either theExes or theWyes has a single element, keep the opposite coordinate
    
    if (theWyes.count < ct) {
        suggestion.width = 0.0;
        suggestion.height = -(firstLoc.height.doubleValue + 5.0);
    } else if (theExes.count < ct) {
        suggestion.height = 0.0;
        suggestion.width = firstLoc.width.doubleValue + 5.0;
    } else {
        suggestion.height = -(firstLoc.height.doubleValue + 5.0);
        suggestion.width = firstLoc.width.doubleValue + 5.0;
    }
    
    return suggestion;
}

- (NSString *)leftOrRight:(CGFloat)dX
{
    if (dX < 0)
        @synchronized([self class]) {
            if (leftStr == nil) {
                leftStr = NSLocalizedString(@"left", @"string that means 'left'");
            }
            return leftStr;
        }
    else if (dX > 0)
        @synchronized([self class]) {
            if (rightStr == nil) {
                rightStr = NSLocalizedString(@"right", @"string that means 'right'");
            }
            return rightStr;
        }
        // zero?
    return @"";
}

- (NSString *)upOrDown:(CGFloat)dY
{
    if (dY < 0)
        @synchronized([self class]) {
            if (downStr == nil) {
                downStr = NSLocalizedString(@"down", @"string that means 'down'");
            }
            return downStr;
        }
    else if (dY > 0)
        @synchronized([self class]) {
            if (upStr == nil) {
                upStr = NSLocalizedString(@"up", @"string that means 'up'");
            }
            return upStr;
        }
        // zero?
    return @"";
}

- (void)askConfirm:(CCEModelledControl *)newModel
              from:(CCEModelledControl *)original
     forController:(CCEControlsViewController *)aController
{
    originalModel = original;
    consideredModel = newModel;
    controller = aController;
    actualControl = controller.selectedControl;
    
    id nib = [[NSNib alloc] initWithNibNamed:@"DuplicatorPanel" bundle:nil];
    NSArray *topLevelObjects;
    [nib instantiateNibWithOwner:self topLevelObjects:&topLevelObjects];
    topObjects = topLevelObjects;
    
    [self.selfProxy setContent:self];
    
    CCELocation *loc = consideredModel.location;
    [location1 setContent:loc];
    [self makeRelativeOffset];
    
        // for steps, get the stepIncrement preference
    NSInteger observeOpts = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:cceStepIncrement
                                               options:observeOpts
                                               context:NULL];
    
    [panel makeKeyAndOrderFront:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:cceStepIncrement]) {
        NSNumber *newVal = [change objectForKey:NSKeyValueChangeNewKey];
        if (newVal != nil) {
            stepIncrementPref = newVal.doubleValue;
        }
    }
}

- (void)makeRelativeOffset
{
    changeInProgress = YES;
    
    double value = consideredModel.location.locX.doubleValue - originalModel.location.locX.doubleValue;
        // changes thru the "self." accessors, for KVO compliance
    self.numDeltaX = [NSNumber numberWithDouble:value];
    
    value = consideredModel.location.locY.doubleValue - originalModel.location.locY.doubleValue;
    self.numDeltaY = [NSNumber numberWithDouble:value];
    
    [self doRelStrings];
    changeInProgress = NO;
}

- (void)doRelStrings
{
    CGFloat value = numDeltaX.doubleValue;
    if (value < 0) {
        self.relX = leftStr;
    } else if (value > 0) {
        self.relX = rightStr;
    }
    
    value = numDeltaY.doubleValue;
    if (value < 0) {
        self.relY = downStr;
    } else if (value > 0) {
        self.relY = upStr;
    }
}

- (IBAction)acceptButton:(id)sender
{
    [panel close];
}
- (IBAction)cancelButton:(id)sender
{
    if (consideredModel.isIndexed) {
        [controller setSelection:actualControl index:1];
    } else {
        [controller setSelection:actualControl];
    }
    [controller deleteSelected:sender forceAll:YES];
    
    [panel close];
}

- (IBAction)moveBy:(id)sender
{
    enum EMoveTags {
        kLeftX10 = 10,
        kLeft1,
        kRight1,
        kRightX10,
        
        kUpX10 = 20,
        kUp1,
        kDown1,
        kDownX10
    };
    
    NSInteger tag = [[sender cell] tagForSegment:[sender selectedSegment]];
    CGFloat xmove = 0.0, ymove = 0.0;
    CGFloat multiply = 1.0;
        // get amount of move (and filter invalid usage)
    switch (tag) {
        case kLeftX10:
        case kRightX10:
        case kUpX10:
        case kDownX10:
            multiply = 10.0;
            break;
            
        case kLeft1:
        case kRight1:
        case kUp1:
        case kDown1:
            multiply = 1.0;
            break;
            
        default:
            NSLog(@"Invalid tag %ld; sender is %@", tag, sender);
            return;
    }
    
        // get direction
    switch (tag) {
        case kLeft1:
        case kLeftX10:
            multiply = -multiply;
                // fall thru
        case kRight1:
        case kRightX10:
            xmove = stepIncrementPref * multiply;
            break;
            
        case kDown1:
        case kDownX10:
            multiply = -multiply;
                // fall thru
        case kUp1:
        case kUpX10:
            ymove = stepIncrementPref * multiply;
            break;
    }
    
    if (!fuzzyZero(xmove)) {
        double value = numDeltaX.doubleValue + xmove;
        self.numDeltaX = [NSNumber numberWithDouble:value];
        
            // simulate edit -- get actions therefrom
        [self valueChange:deltaX];
    }
    if (!fuzzyZero(ymove)) {
        double value = numDeltaY.doubleValue + ymove;
        self.numDeltaY = [NSNumber numberWithDouble:value];
        
            // simulate edit
        [self valueChange:deltaY];
    }
}

    // when a value changes,
    //  1: apply relative to absolute or vice versa
    //  2: for indexed controls, apply to all parts
- (IBAction)valueChange:(id)sender
{
        // Change causes change in another control == infinite recursion.  Stop it here!
    if (changeInProgress) {
        return;
    }
    
    enum EChange {
        kAbsX = 1,
        kAbsY,
        kRelX,
        kRelY,
        
        kSomethingElse = -1
    };
    
    int changeType;
    if (sender == absX) {
        changeType = kAbsX;
    } else if (sender == absY) {
        changeType = kAbsY;
    } else if (sender == deltaX) {
        changeType = kRelX;
    } else if (sender == deltaY) {
        changeType = kRelY;
    } else {
        changeType = kSomethingElse;
    }
    
    double value;
    
    changeInProgress = YES;
    
        // changes thru the "self." accessor, for KVO compliance
    switch (changeType) {
        case kAbsX:
            value = consideredModel.location.locX.doubleValue - originalModel.location.locX.doubleValue;
            self.numDeltaX = [NSNumber numberWithDouble:value];
            break;
            
        case kAbsY:
            value = consideredModel.location.locY.doubleValue - originalModel.location.locY.doubleValue;
            self.numDeltaY = [NSNumber numberWithDouble:value];
            break;
            
        case kRelX:
            value = originalModel.location.locX.doubleValue + numDeltaX.doubleValue;
            self.consideredModel.location.locX = [NSNumber numberWithDouble:value];
            break;
            
        case kRelY:
            value = originalModel.location.locY.doubleValue + numDeltaY.doubleValue;
            self.consideredModel.location.locY = [NSNumber numberWithDouble:value];
            break;
            
        default:
            NSLog(@"%@ valueChange: invalid sender %@", [self class], sender);
            changeInProgress = NO;
            return;
    }
    
    if (consideredModel.isIndexed) {
            // "location" is index 1; need 2 thru "numParts"
        NSInteger numparts = consideredModel.numParts.integerValue;
        CCEMultiCheckModel *oIndexedModel = (CCEMultiCheckModel *)originalModel;
        CCEMultiCheckModel *cIndexedModel = (CCEMultiCheckModel *)consideredModel;
        CCELocation *oIndexedLoc, *cIndexedLoc;
        for (NSInteger index = 2; index <= numparts; ++index) {
            oIndexedLoc = [oIndexedModel locationWithIndex:index];
            cIndexedLoc = [cIndexedModel locationWithIndex:index];
            switch (changeType) {
                case kAbsX:
                case kRelX:
                    value = oIndexedLoc.locX.doubleValue + numDeltaX.doubleValue;
                    cIndexedLoc.locX = [NSNumber numberWithDouble:value];
                    break;
                    
                case kAbsY:
                case kRelY:
                    value = oIndexedLoc.locY.doubleValue + numDeltaY.doubleValue;
                    cIndexedLoc.locY = [NSNumber numberWithDouble:value];
                    break;
                    
                default:
                        // can't get here; weeded out (and logged) above
                    break;
            }
        }
        
        [self doRelStrings];
        changeInProgress = NO;
    }
}

    // window delegate...
- (void)windowWillClose:(NSNotification *)notification
{
    if ([notification object] == panel) {
        [(AppDelegate *)[NSApp delegate] cleanupNibObjects:topObjects];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:cceStepIncrement];
}

@end
