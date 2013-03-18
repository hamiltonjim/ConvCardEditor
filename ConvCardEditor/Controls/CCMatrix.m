//
//  CCMatrix.m
//  CCardX
//
//  Created by Jim Hamilton on 8/29/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCMatrix.m,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import <Foundation/NSObjCRuntime.h>
#import "CCMatrix.h"
#import "AppDelegate.h"
#import "CCEMultiCheckModel.h"
#import "CCBoxMatrix.h"
#import "CCLeadChoiceMatrix.h"
#import "CCELocationController.h"
#import "NSView+ScaleUtilities.h"

@interface CCMatrix ()

@property NSUInteger debugIndex;
@property (nonatomic) int debugMode;

@property (readwrite) BOOL isReindexing;

@property (weak) id myTarget;
@property SEL myAction;

@end

@implementation CCMatrix
{
    NSRect trueBounds;
    BOOL needTrueBounds;

}

@synthesize controls;
@synthesize allowsEmptySelection;
@synthesize allowsMultiSelection;

@synthesize selected;
@synthesize value;

@synthesize name;

@synthesize debugMode;
@synthesize debugIndex;

@synthesize isReindexing;

@synthesize myTarget;
@synthesize myAction;

@synthesize locationController;
@synthesize modelledControl;

- (NSString *)valueBindingTransformerName
{
    return cceStringToIntegerTransformer;
}

    // The matrixFromModel: and matrixFromModel:insideRect: factory methods create
    // the appropriate subclass object; note that the factory calls methods named
    // matrixWithModel:indideRect: methods on each one; the name change is subtle,
    // but crucial to prevent an infinite recursion when (say) the factory method
    // in the subclass is not implemented.
+ (CCMatrix *)matrixFromModel:(CCEMultiCheckModel *)model
{
    return [self matrixFromModel:model insideRect:NSZeroRect];
}
+ (CCMatrix *)matrixFromModel:(CCEMultiCheckModel *)model insideRect:(NSRect)rect
{
    NSInteger shape;
    if (model.shape == nil) {
        NSLog(@"no shape specified; default to checkboxes");
        shape = kCheckboxes;
    } else
        shape = model.shape.integerValue;
    
    CCMatrix *control = nil;
    switch (shape) {
        case kCheckboxes:
            control = [CCBoxMatrix matrixWithModel:model insideRect:rect];
            break;
            
        case kOvals:
            control = [CCLeadChoiceMatrix matrixWithModel:model insideRect:rect];
            break;
            
        default:
            [NSException raise:@"unknownMatrixType"
                        format:@"%@ unknown matrix type %ld", self, (long)shape];
            break;
    }
    if (control != nil) {
        [control monitorModel:model];
    }
    
    return control;
}

- (id)monitorModel:(CCEModelledControl *)model
{
    modelledControl = model;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[controls count]];
        // monitoring -- remember 1-basedness of indices
    [controls enumerateObjectsUsingBlock:^(NSControl <CCDebuggableControl>* ctl, NSUInteger idx, BOOL *stop) {
        CCELocationController *locCtl = [[CCELocationController alloc] initWithModel:model
                                                                               index:idx + 1
                                                                             control:self];
        [array addObject:locCtl];
    }];
    locationController = array;
    
    return locationController;
}

- (id)monitorModel:(CCEModelledControl *)model index:(NSUInteger)index
{
    NSUInteger count = controls.count;
    if (count < index) {
        [NSException raise:@"BadIndex"
                    format:@"Attempt to add sub controls out of order: index[%ld] count[%ld]",
         index, count];
    }
    
    modelledControl = model;
        // monitoring -- remember 1-basedness of indices
    CCELocationController *locCtl = [[CCELocationController alloc] initWithModel:model
                                                                           index:index
                                                                         control:self];
    
    if (nil == locationController) {
        locationController = [NSMutableArray array];
    }
    NSMutableArray *array = locationController;
    if (index < count) {
        [array replaceObjectAtIndex:(index - 1) withObject:locCtl];
    } else {
        [array addObject:locCtl];
    }
    
    return locationController;
}

- (void)stopMonitoring
{
    if (locationController == nil || ![locationController isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    
    NSMutableArray *array = locationController;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(stopMonitoringLocation)]) {
            CCELocationController *ctlr = obj;
            [ctlr stopMonitoringLocation];
        }
    }];
    [array removeAllObjects];
}

- (void)setTarget:(id)anObject
{
    myTarget = anObject;
    [super setTarget:anObject];
}
- (void)setAction:(SEL)aSelector
{
    myAction = aSelector;
    [super setAction:aSelector];
}

static NSInteger 
mask2index(NSUInteger mask) {
    NSInteger index = -1;
    
    while (mask) {
        mask >>= 1;
        ++index;
    }
    return index;
}

+ (void) initialize {
    if (self == [CCMatrix class])
        [self exposeBinding:NSValueBinding];
}

+ (id) cellClass {
    return nil;
}

- (id) initWithFrame:(NSRect)bounds name:(NSString *)matrixName {
    if ((self = [super initWithFrame:[NSView defaultScaleRect:bounds]])) {
        isReindexing = NO;
        name = matrixName;
        selected = nil;
        needTrueBounds = YES;
    }
    return self;
}

- (void) choose {
    NSInteger ival = -1;
    
    if (value) ival = [value integerValue];
    
    for (NSControl *ctrl in controls) {
        [ctrl setIntegerValue:0];
    }
    
    [self updateBoundObjects];
    
    if (allowsMultiSelection) {
        if (ival < 0) return;
        
        NSInteger maxIndex = [controls count] - 1;
        while (ival) {
                // get right-most 1 bit
                // property of 2's complement integers: 
            NSUInteger rightmost = ival & -ival;
                // mask -> index
            NSInteger index = mask2index(rightmost);
            if (index > maxIndex) break;
            
            NSControl *it = (NSControl *)[controls objectAtIndex:index];
            [it setIntegerValue:1];
            
            ival -= rightmost;
        }
        
        selected = nil;
    } else {
        if (ival <= 0 || ival > [controls count]) return;
        
        NSControl *it = (NSControl *)[controls objectAtIndex:ival - 1];
        selected = it;
        [it setIntegerValue:1];
    }
}

- (void) updateBoundObjects {
    NSDictionary *bdict = [self infoForBinding:NSValueBinding];
    if (bdict) {
        NSObject *obj = [bdict objectForKey:NSObservedObjectKey];
        NSString *path = [bdict objectForKey:NSObservedKeyPathKey];
        id setVal = value;
        NSValueTransformer *xformer = nil;
        NSDictionary *options = [bdict objectForKey:NSOptionsKey];
        if (options) {
            xformer = [options objectForKey:NSValueTransformerBindingOption];
        }
        if (xformer) {
            setVal = [xformer reverseTransformedValue:value];
        }
        
        if (obj)
            [obj setValue:setVal forKeyPath:path];
    }
}

- (void)setValue:(NSNumber *)aVal {
    value = aVal;
    
    [self choose];
}
- (NSNumber *)value {
    return value;
}

-(BOOL) validateValue:(id *)ioValue error:(NSError **)outError {
    if ([*ioValue respondsToSelector:@selector(integerValue)]) {
        NSInteger val = [*ioValue integerValue];
        if (val >= 0 && val < [controls count])
            return YES;
    } else if (nil == *ioValue) {
        return YES;
    }
    
    
    NSString *estr = @"invalid value";
    NSDictionary *dct = [NSDictionary dictionaryWithObject:estr forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:applicationDomain code:-1 userInfo:dct];
    if (outError)
        *outError = error;
    return NO;
}

#pragma mark PROTOCOL CCctrlParent
- (void)notify:(NSControl *)sender {
    [CCDebuggableControlEnable logIfWanted:sender.tag inMatrix:self];
    
    if (allowsMultiSelection) {
        NSInteger ival = 0;
        NSInteger mask = 1;
        for (NSControl *ctrl in controls) {
            if ([ctrl integerValue])
                ival |= mask;
            mask <<= 1;
        }
        
        selected = nil;
        self.value = [NSNumber numberWithInteger:ival];
    } else {
        if ([sender integerValue]) {
            if (selected) {
                [selected setIntegerValue:0];
            }
            
            selected = sender;
            self.value = [NSNumber numberWithInteger:[selected tag]];
        } else if (allowsEmptySelection && selected == sender) {
            selected = nil;
            self.value = nil;
        }
    }
    
    [self sendAction:myAction to:myTarget];
}

- (NSControl *)childWith1Index:(NSUInteger)index
{
        // indices shifted by 1; fix
    return [controls objectAtIndex:--index];
}

- (NSInteger)reindexFrom:(NSUInteger)fromIndex
                      to:(NSUInteger)toIndex
                   error:(NSError *__autoreleasing *)error
{
        // ignore more reindex messages while reindexing
    if (isReindexing)
        return kNoError;
    
    NSUInteger max = [controls count];
    if (fromIndex < 1 || fromIndex > max) {
        return kOldIndexOutOfRange;
    }

    NSError *theErr = nil;
    
    @try {
        isReindexing = YES;     // undo in "@finally" block
        
        if (toIndex < 1 || toIndex > max) {
                // this is pilot error: disallow and restore
            NSArray *locs = locationController;
            CCELocationController *loc = [locs objectAtIndex:(fromIndex - 1)];
            loc.watchedLocation.index = [NSNumber numberWithInteger:fromIndex];
            
            NSString *descrStr = NSLocalizedString(@"Index is out of range", @"Index out of range");
            NSString *reasonFmtStr = NSLocalizedString(@"The %@ index must fall between 1 and %ld",
                                                       @"Format string for range index");
            NSString *reasonStr = [NSString stringWithFormat:reasonFmtStr, [self shapeName:kPossessive], max];
            NSDictionary *dict = @{
                                   NSLocalizedDescriptionKey: descrStr,
                                   NSLocalizedFailureReasonErrorKey: reasonStr
                                   };
            
            
            theErr = [NSError errorWithDomain:applicationDomain code:2001 userInfo:dict];
            
            return kIndexOutOfRange;
        }
        
            // fix base: start at zero, not 1
        --fromIndex;
        --toIndex;
    
        id <CCDebuggableControl> child = [controls objectAtIndex:fromIndex];
        [controls removeObjectAtIndex:fromIndex];
        [controls insertObject:child atIndex:toIndex];
        
        if (locationController != nil) {
            NSMutableArray *array = locationController;
            CCELocationController *locCtl = [array objectAtIndex:fromIndex];
            [array removeObjectAtIndex:fromIndex];
            [array insertObject:locCtl atIndex:toIndex];
            
                // reindex and retag from position in location controller
            [array enumerateObjectsUsingBlock:^(CCELocationController *obj, NSUInteger idx, BOOL *stop) {
                    // fix (1-based) indices
                ++idx;
                obj.watchedLocation.index = [NSNumber numberWithInteger:idx];
                [obj.viewedControl setTag:idx];
            }];
        }
    }
    @catch (NSException *exception) {
            // don't really know how to catch, so just re-throw
        @throw exception;
    }
    @finally {
        isReindexing = NO;
        if (error != NULL) {
            *error = theErr;
        }
    }
    return (theErr == nil) ? kNoError : kUnknownError;
}

#pragma mark VALUE

    // pass bind to child controls, if it is a "hidden" binding
- (void) bind:(NSString *)binding toObject:(id)observable
  withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    if ([binding compare:@"hidden" options:0 range:NSMakeRange(0, 6)] == NSOrderedSame)
         for (NSControl *ctrl in controls) {
             [ctrl bind:binding toObject:observable withKeyPath:keyPath options:options];
         }
    else {
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    }

}

- (void) setShortValue:(short)aShort {
    [self setValue:[NSNumber numberWithShort:aShort]];
}
- (void) setIntValue:(int)aVal {
    [self setValue:[NSNumber numberWithInt:aVal]];
}
- (void) setIntegerValue:(NSInteger)anInteger {
    [self setValue:[NSNumber numberWithInteger:anInteger]];
}
- (void) setFloatValue:(float)aFloat {
    [self setValue:[NSNumber numberWithFloat:aFloat]];
}
- (void) setDoubleValue:(double)aDouble {
    [self setValue:[NSNumber numberWithDouble:aDouble]];
}
- (void)setStringValue:(NSString *)aString
{
    self.value = [NSNumber numberWithDouble:aString.doubleValue];
}

- (short) shortValue {
    return value.shortValue;
}
- (int) intValue {
    return value.intValue;
}
- (NSInteger) integerValue {
    return value.integerValue;
}
- (float) floatValue {
    return value.floatValue;
}
- (double) doubleValue {
    return value.doubleValue;
}
- (NSString *)stringValue
{
    return value.stringValue;
}

#pragma mark DELETION AND INDEXING
    // remove selected child control; removing the last child removes the parent as well
- (BOOL)deleteChild:(id<CCDebuggableControl>)child
{
    BOOL deleteParent = NO;
    
    if (debugIndex > 0) {
        [self removeChild:debugIndex];
        
            // reset selected child (nearest to old value)
        deleteParent = [controls count] == 0;
        
        if (debugIndex > [controls count]) {
            --debugIndex;
        }
    }
    
    return deleteParent;
}

- (NSUInteger)currentIndex
{
    return debugIndex;
}

- (NSControl <CCDebuggableControl> *)removeChild:(NSUInteger)index
{
        // remember the bias: 1-based children
    NSUInteger delIndex = index - 1;
        // we're going to delete it from its superview!  Make strong reference...
    NSControl <CCDebuggableControl> * __strong removed = [controls objectAtIndex:delIndex];
    
    [controls removeObjectAtIndex:delIndex];
    CCEMultiCheckModel *theModel = (CCEMultiCheckModel *)modelledControl;
        // reindex model
    [theModel removeLocationWithIndex:index];
    
        // reindex -- meaning, set tag to correct (1-based) index of each child
    [controls enumerateObjectsUsingBlock:^(NSControl *child, NSUInteger idx, BOOL *stop) {
        [child setTag:idx + 1];
        [child setNeedsDisplay];
    }];
    
    [removed removeFromSuperview];
    return removed;
}

- (void)addChildControl:(NSControl <CCDebuggableControl> *)child
{
    NSRect cFrame = child.frame;
    NSRect myFrame = self.frame;
    NSPoint diffPt = NSMakePoint(myFrame.origin.x - cFrame.origin.x,
                                 myFrame.origin.y - cFrame.origin.y);
    [self setFrame:NSUnionRect(myFrame, cFrame)];
    if (diffPt.x > 0.0 || diffPt.y > 0.0) {
        diffPt.x = MAX(diffPt.x, 0.0);
        diffPt.y = MAX(diffPt.y, 0.0);
        [self.controls enumerateObjectsUsingBlock:^(NSView *ctl, NSUInteger idx, BOOL *stop) {
            NSPoint cOrigin = ctl.frame.origin;
            cOrigin.x += diffPt.x;
            cOrigin.y += diffPt.y;
            [ctl setFrameOrigin:cOrigin];
        }];
    }
    [child setFrame:[self convertRect:cFrame fromView:[self superview]]];
    [child setParent:self];
    [self addSubview:child];
    [self.controls addObject:child];
    [self tagChild:child];
}

- (NSUInteger)tagChild:(NSControl<CCDebuggableControl> *)child
{
    NSUInteger index = [controls indexOfObject:child];
    if (index == NSNotFound) {
            // remember, child indices start at 1; zero is our "not found"
        return 0;
    }
    
    [child setTag:++index];
    return index;
}

- (void) placeChildControlsInRects:(NSArray *)rects {
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[rects count]];
    NSInteger ctr = 0;
    
    NSPoint origin = [NSView defaultUnscalePoint:self.frame.origin];
    for (NSValue *rv in rects) {
        NSRect theRect = NSOffsetRect([rv rectValue], -origin.x, -origin.y);
            //was: [self convertRect:[rv rectValue] fromView:[self superview]];
        NSControl <CCDebuggableControl> *cbox = [self createChildInRect:theRect];
        [self addSubview:cbox];
        [cbox setParent:self];
        [tmpArray addObject:cbox];
        [cbox setTag:++ctr];
    }
    
    self.controls = tmpArray;
}

- (NSString *)description
{
    NSString *start = [NSString stringWithFormat:@"%@ name '%@' value %ld \n\tframe: %@\n\tbounds: %@",
                       self.class, self.name, self.integerValue,
                       NSStringFromRect(self.frame), NSStringFromRect(self.bounds)];
    NSMutableString *subviewStrs = [NSMutableString string];
    NSUInteger svCount = self.subviews.count;
    NSString *svClass = svCount ? NSStringFromClass([[self.subviews objectAtIndex:0] class]) : @"<none>";
    [subviewStrs appendFormat:@"\n%ld subviews (%@): {", svCount, svClass];
    NSInteger ctr = 0;
    for (NSControl *sv in self.subviews) {
        [subviewStrs appendFormat:@"\n\t%ld: value: %ld frame: %@",
         ++ctr, sv.integerValue, NSStringFromRect(sv.frame)];
    }
    if (svCount) [subviewStrs appendString:@"\n"];
    [subviewStrs appendString:@"}"];
    return [start stringByAppendingString:subviewStrs];
}

#pragma mark SUBCLASS RESPONSIBILITIES
- (void)subclassResponsibility:(SEL)sel
{
    [NSException raise:@"SubclassResponsibility"
                format:@"Method %@ must be defined in %@",
     NSStringFromSelector(sel), NSStringFromClass([self class])];

}

- (NSControl <CCDebuggableControl> *)createChildInRect:(NSRect)theRect
{
    [self subclassResponsibility:@selector(createChildInRect:)];
    return nil;
}

- (void)placeChildInRect:(NSRect)rect withColor:(NSColor *)color
{
    [self subclassResponsibility:@selector(placeChildInRect:withColor:)];

}

- (void)placeChildInRect:(NSRect)rect withColorCode:(NSInteger)colorCode
{
    [self subclassResponsibility:@selector(placeChildInRect:withColorCode:)];
}

- (void)placeChildInRect:(NSRect)rect withColorKey:(NSString *)colorKey
{
    [self subclassResponsibility:@selector(placeChildInRect:withColorKey:)];
}

- (void)placeChildWithLocation:(NSManagedObject *)location withColor:(NSColor *)color
{
    [self subclassResponsibility:@selector(placeChildWithLocation:withColor:)];
}

- (void)placeChildWithLocation:(NSManagedObject *)location withColorCode:(NSInteger)colorCode
{
    [self subclassResponsibility:@selector(placeChildWithLocation:withColorCode:)];
}

- (void)placeChildWithLocation:(NSManagedObject *)location withColorKey:(NSString *)colorKey
{
    [self subclassResponsibility:@selector(placeChildWithLocation:withColorKey:)];
}

- (NSString *)shapeName:(NSInteger)nounCase
{
    [self subclassResponsibility:@selector(shapeName:)];
    return @"DO NOT DISPLAY!";
}

#pragma mark EDIT / DEBUG
    // Debug mode requires an index; save the last one seen in case the non-indexed
    // form is called (it will be...)
- (void) setDebugMode:(int)val {
    [self setDebugMode:val index:debugIndex];
}

    // For kShowSelected only:  show the part with the selected index
    // as selected, and the other parts as "selected-other"; for other modes,
    // just pass the given mode through to all children.  A selection index of
    // zero leaves the selection unchanged
- (void)setDebugMode:(int)newDebugMode index:(NSInteger)index
{
    debugMode = newDebugMode;
    
    if (index > 0)
        debugIndex = index;
    
    [controls enumerateObjectsUsingBlock:^(NSControl <CCDebuggableControl> *obj, NSUInteger idx, BOOL *stop) {
        int setMode = newDebugMode;
        if (setMode == kShowSelected)
            setMode = (idx + 1 == debugIndex) ? kShowSelected : kShowSelectedOther;
        [obj setDebugMode:setMode];
    }];
}

    // return the union of all cell rects (not including self's rect)
- (NSRect)unionCellRects
{
    NSRect unionRect = NSZeroRect;
    
    NSView *targetView = self.superview;
    
    for (NSControl *ctl in controls) {
        NSRect curRect = [targetView convertRect:ctl.frame fromView:self];
        unionRect = NSUnionRect(unionRect, curRect);
    }
    
    return unionRect;
}

#pragma mark TESTING

- (void)advanceTest
{
    NSInteger ival = self.integerValue;
    if (ival++ >= controls.count) {
        ival = 0;
    }
    [self setIntegerValue:ival];
}

- (void)resetTest
{
    self.integerValue = 0;
}

@end
