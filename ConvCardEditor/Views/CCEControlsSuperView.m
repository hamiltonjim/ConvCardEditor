//
//  CCEControlsSuperView.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/23/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEControlsSuperView.h"
#import "CCEControlsViewController.h"
#import "NSView+ScaleUtilities.h"
#import "CCDebuggableControl.h"
#import "CCELocation.h"
#import "CommonStrings.h"
#import "CCEModelledControl.h"
#import "CCMatrix.h"
#import "FixedNSImageView.h"
#import "CCESizableTextField.h"
#import "CCDebuggableControlEnable.h"

enum EArrowKeyMultipliers {
    kMove = 0,
    kMoveWord,
    kMoveToEndOfLine,
    
    };

@interface CCEControlsSuperView ()

    // dragging rectangle
@property NSPoint mouseDownPoint;
@property NSColor *selectionDragColor;
@property NSRect lastDragRect;
@property BOOL inDrag;

@end

@implementation CCEControlsSuperView

@synthesize zoom;
@synthesize viewController;
@synthesize superImageView;

@synthesize gridState;

@synthesize mouseDownPoint;
@synthesize selectionDragColor;
@synthesize lastDragRect;
@synthesize inDrag;

- (void)awakeFromNib
{
    selectionDragColor = [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.25];
    lastDragRect = NSZeroRect;
    inDrag = NO;
}

    // view is co-incident with its superview's image
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    NSRect rect = superImageView.frame;
//    NSLog(@"%@ resize from %@ to %@", [self class],
//          NSStringFromSize(oldSize), NSStringFromSize(rect.size));
    [self setFrame:rect];
}

- (void)placeView:(NSView <CCDebuggableControl> *)view
{
    CCEModelledControl *ctl = [view modelledControl];
    
    CCELocation *location = [ctl valueForKey:ccModelLocation];
    if (location) {
        [self placeIndividualView:view at:location];
        return;
    }
    
        // otherwise, it should be a list of locations...
    NSSet *locSet = [ctl valueForKey:ccModelMultiLocations];
    
        // ...and the control should be a type of CCMatrix
    CCMatrix *mat = nil;
    if ([view isKindOfClass:[CCMatrix class]]) {
        mat = (CCMatrix *)view;
    }
    
    if (mat == nil) {
        return;
    }
    NSArray *ownedCtls = [mat controls];
    
    [locSet enumerateObjectsUsingBlock:^(CCELocation *loc, BOOL *stop) {
        NSInteger index = [[loc index] integerValue];
        NSControl <CCDebuggableControl> *indControl = [ownedCtls objectAtIndex:index];
        if (indControl != nil) {
            [self placeIndividualView:indControl at:loc];
        }
    }];
    
}

- (void)setGridState:(BOOL)state
{
    if (gridState != state) {
        gridState = state;
        [self setNeedsDisplay:YES];
    }
}

- (void)placeIndividualView:(NSView *)view at:(CCELocation *)location
{
    double x = [[location locX] doubleValue];
    double y = [[location locY] doubleValue];
    double width = [[location width] doubleValue];
    double height = [[location height] doubleValue];
    
    NSRect frame = NSMakeRect(x, y, width, height);
    [view setFrame:frame];
}

    // draws a grid,
- (void)drawRect:(NSRect)dirtyRect
{
    if ([viewController editMode] && gridState) {
        
        NSSize isize = [self bounds].size;
        
        NSBezierPath *path;
        [[NSColor colorWithDeviceRed:0.0 green:0.2 blue:1.0 alpha:0.4] set];
        
        double unitDivisor;
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:ccDimensionUnit]) {
            case kCentimetersDimension:
                unitDivisor = kCentimeterDivisor;
                break;
                
            case kPointsDimension:
            case kInchesDimension:
                unitDivisor = kInchDivisor;
                break;
                
            default:
                [NSException raise:@"InvalidDimensionConstant"
                            format:@"Dimension must be one of {Points, inches, centimeters"];
                break;
        }
        
            // draw to scale (whatever that is right now)
        CGFloat scale = [superImageView zoomFactor];
        unitDivisor *= scale;
        
        for (double x = 0.0; x < isize.width; x += unitDivisor) {
            path = [NSBezierPath bezierPath];
            [path setLineWidth:0.0];
            [path moveToPoint:NSMakePoint(x, 0.0)];
            [path lineToPoint:NSMakePoint(x, isize.height)];
            [path stroke];
        }
        
        for (double y = 0.0; y < isize.height; y += unitDivisor) {
            path = [NSBezierPath bezierPath];
            [path setLineWidth:0.0];
            [path moveToPoint:NSMakePoint(0.0, y)];
            [path lineToPoint:NSMakePoint(isize.width, y)];
            [path stroke];
        }
        
        if (inDrag) {
            [selectionDragColor set];
            path = [NSBezierPath bezierPathWithRect:lastDragRect];
            [path fill];
        }
    }
    
    [super drawRect:dirtyRect];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    mouseDownPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [viewController viewMouseDown:theEvent];
    lastDragRect = NSZeroRect;
    [CCDebuggableControlEnable logIfWanted:theEvent inView:self];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (inDrag) {
        inDrag = NO;
        [self setNeedsDisplayInRect:lastDragRect];
        lastDragRect = NSZeroRect;
    }
    
    [CCDebuggableControlEnable logIfWanted:theEvent inView:self];
    [viewController viewMouseUp:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if ([viewController viewMouseDragged:theEvent] == NO)
        return;
    
    inDrag = YES;
    
        // mark the previous drag rect...
    NSRect oldRect = lastDragRect;
    
    NSPoint dragPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
        // ... and the new drag rect
    lastDragRect = JFH_RectFromPoints(mouseDownPoint, dragPoint);
    NSRect unionRect = NSUnionRect(oldRect, lastDragRect);
    [self setNeedsDisplayInRect:unionRect];
}

- (void)keyDown:(NSEvent *)theEvent
{
        // Arrow keys are associated with the numeric keypad
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
        NSString *arrowKey = theEvent.charactersIgnoringModifiers;
        
        if (arrowKey.length == 0)
            return;     // ignore dead keys
        unichar theArrow = [arrowKey characterAtIndex:0];
        
        CGFloat multiplier = 1.0;
        NSUInteger modifierFlags = theEvent.modifierFlags;
        if (modifierFlags & NSAlternateKeyMask)
            multiplier = 0.1;
        else if (modifierFlags & NSCommandKeyMask)
            multiplier = 10.0;
        
        BOOL shifted = 0 != (modifierFlags & NSShiftKeyMask);
        switch (theArrow) {
            case NSLeftArrowFunctionKey:
                if (shifted) {
                    [viewController shrinkH:multiplier];
                } else {
                    [viewController nudgeLeft:multiplier];
                }
                break;
                
            case NSRightArrowFunctionKey:
                if (shifted) {
                    [viewController growH:multiplier];
                } else {
                    [viewController nudgeRight:multiplier];
                }
                break;
                
            case NSUpArrowFunctionKey:
                if (shifted) {
                    [viewController growV:multiplier];
                } else {
                    [viewController nudgeUp:multiplier];
                }
                break;
                
            case NSDownArrowFunctionKey:
                if (shifted) {
                    [viewController shrinkV:multiplier];
                } else {
                    [viewController nudgeDown:multiplier];
                }
                break;
                
            default:
                [super keyDown:theEvent];
                break;
        }
    } else {
        [super keyDown:theEvent];
    }
}


@end
