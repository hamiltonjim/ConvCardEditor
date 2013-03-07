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

static const CGFloat stdOffsetBy = 5.0;
static CCEDuplicator *theInstance = nil;

static NSString *leftStr;
static NSString *rightStr;
static NSString *upStr;
static NSString *downStr;

@interface CCEDuplicator ()

@property (readwrite) NSString *relX;
@property (readwrite) NSString *relY;

@property CCEModelledControl *originalModel;
@property CCEModelledControl *consideredModel;
@property CCEControlsViewController *controller;

@property NSControl <CCDebuggableControl> *actualControl;

- (id)newEntityModel:(NSManagedObject *)original;

- (CCETextModel *)cloneText:(NSManagedObject *)original offsetBy:(NSSize)offset;
- (CCEMultiCheckModel *)cloneMultiCheck:(NSManagedObject *)original offsetBy:(NSSize)offset;
- (CCESingleCheckModel *)cloneSingleCheck:(NSManagedObject *)original offsetBy:(NSSize)offset;
- (CCELocation *)cloneLocation:(NSManagedObject *)original offsetBy:(NSSize)offset;

- (NSString *)leftOrRight:(CGFloat)dX;
- (NSString *)upOrDown:(CGFloat)dY;

- (NSSize)suggestOffset:(NSSet *)locations;

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

- (id)cloneModel:(NSManagedObject *)original
{
        // place new object down and to right by std amount
    return [self cloneModel:original offsetBy:NSMakeSize(0, 0)];
}

- (NSManagedObject *)cloneModel:(NSManagedObject *)original offsetBy:(NSSize)offset
{
    if ([original.entity.name isEqualToString:entityLocation]) {
        return [self cloneLocation:original offsetBy:offset];
    } else if ([original.entity.name isEqualToString:entityText]) {
        return [self cloneText:original offsetBy:offset];
    } else if ([original.entity.name isEqualToString:entityMultiCheck]) {
        return [self cloneMultiCheck:original offsetBy:offset];
    } else if ([original.entity.name isEqualToString:entityCheckbox]) {
        return [self cloneSingleCheck:original offsetBy:offset];
    }
    
        // if we get here, something is badly wrong...
    [NSException raise:@"UnknownModelType"
                format:@"Attempt to clone unknown model of type %@", original.entity.name];
        // make the "no return" warning go away...
    return nil;
}

- (NSManagedObject *)newEntityModel:(NSManagedObject *)original
{
    return [NSEntityDescription insertNewObjectForEntityForName:original.entity.name
                                         inManagedObjectContext:original.managedObjectContext];
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
    
}

- (CCEMultiCheckModel *)cloneMultiCheck:(CCEMultiCheckModel *)original offsetBy:(NSSize)offset
{
    if (NSEqualSizes(offset, NSMakeSize(0.0, 0.0))) {
        offset = [self suggestOffset:original.locations];
    }
    
    CCEMultiCheckModel *model = [self newEntityModel:original];
    
    model.dimX = original.dimX;
    model.dimY = original.dimY;
    model.shape = original.shape;
    
    NSMutableSet *newlocs = [model mutableSetValueForKey:@"locations"];
    for (CCELocation* loc in original.locations) {
        [newlocs addObject:[self cloneLocation:loc offsetBy:offset]];
    }
    
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
    [nib instantiateNibWithOwner:self topLevelObjects:nil];
    
    CCELocation *loc = consideredModel.location;
    [location1 setContent:loc];
    
    [panel makeKeyAndOrderFront:self];
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

- (IBAction)valueChange:(id)sender
{
    
}

@end
