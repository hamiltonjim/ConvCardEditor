//
//  CCESizableTextFieldCell.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/24/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCESizableTextFieldCell.h"
#import "CCESizableTextField.h"
#import "CommonStrings.h"
#import "CCDebuggableControl.h"
#import "CCEModelledControl.h"
#import "NSView+ScaleUtilities.h"

const CGFloat kInsetPoints = 4.0;
const NSPoint kInsetSize = {kInsetPoints, kInsetPoints};

const CGFloat kHandleRadius = 3.0;
const CGFloat kHandleDiameter = kHandleRadius * 2.0;


static NSColor *selectedColor;
static NSColor *unselectedColor;
static NSColor *highlightColor;

@interface CCESizableTextFieldCell ()

@property BOOL inDrag;
@property int dragIndex;
@property NSPoint dragStartPoint;

@property CGFloat scale;

- (NSRect)fillOvalAt:(NSRect)ovalRect;

- (NSRect)dotRectAroundX:(CGFloat)x y:(CGFloat)y;

- (void)reFrame:(NSView *)controlView at:(NSRect)rect;

@end

@implementation CCESizableTextFieldCell

@synthesize textRect;
@synthesize borderRect;
@synthesize useDoubleHandles;

@synthesize dragRectArray;
@synthesize debugMode;

@synthesize inDrag;
@synthesize dragIndex;
@synthesize dragStartPoint;

@synthesize scale;

+ (void)initialize
{
    if (self == [CCESizableTextFieldCell class]) {
        selectedColor = [NSColor blackColor];
        unselectedColor = [NSColor colorWithCalibratedWhite:0.6 alpha:0.8];
        highlightColor = [NSColor colorWithCalibratedRed:HIGHLIGHT_COLOR_R
                                                   green:HIGHLIGHT_COLOR_G
                                                    blue:HIGHLIGHT_COLOR_B
                                                   alpha:HIGHLIGHT_COLOR_A];
    }
}

+ (NSPoint)insetSize
{
    return kInsetSize;
}

- (id)monitorModel:(CCEModelledControl *)model
{
    [NSException raise:@"NotImplementedInCell"
                format:@"monitorModel should not be implemented in cell class %@", [self class]];
    return nil;
}

- (id)initTextCell:(NSString *)aString
{
    if ((self = [super initTextCell:aString])) {
        [self sendActionOn:NSLeftMouseUpMask];
        inDrag = NO;
    }
    
    return self;
}

- (id)initImageCell:(NSImage *)image
{
    if ((self = [super initImageCell:image])) {
        [self sendActionOn:NSLeftMouseUpMask];
        inDrag = NO;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self sendActionOn:NSLeftMouseUpMask];
        inDrag = NO;
    }
    return self;
}

- (NSRect)dotRectAroundX:(CGFloat)x y:(CGFloat)y
{
    return NSMakeRect(x - kHandleRadius, y - kHandleRadius, kHandleDiameter, kHandleDiameter);
}

- (void)calcDrawInfo:(NSRect)aRect
{
    textRect = NSInsetRect(aRect, kHandleDiameter, kHandleDiameter);
    
    borderRect = NSInsetRect(aRect, kHandleRadius, kHandleRadius);
    
    _dragRect[kLeft] = [self dotRectAroundX:NSMinX(borderRect) y:NSMidY(borderRect)];
    _dragRect[kRight] = [self dotRectAroundX:NSMaxX(borderRect) y:NSMidY(borderRect)];
    
    _dragRect[kTop] = [self dotRectAroundX:NSMidX(borderRect) y:NSMaxY(borderRect)];
    _dragRect[kBottom] = [self dotRectAroundX:NSMidX(borderRect) y:NSMinY(borderRect)];
    
    if (useDoubleHandles) {
        _dragRect[kBottomLeft] = [self dotRectAroundX:NSMinX(borderRect) y:NSMinY(borderRect)];
        _dragRect[kBottomRight] = [self dotRectAroundX:NSMaxX(borderRect) y:NSMinY(borderRect)];
        _dragRect[kTopLeft] = [self dotRectAroundX:NSMinX(borderRect) y:NSMaxY(borderRect)];
        _dragRect[kTopRight] = [self dotRectAroundX:NSMaxX(borderRect) y:NSMaxY(borderRect)];
    }
    
    NSInteger kMax = useDoubleHandles ? kDoubleHandleCount : kSimpleHandleCount;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:kMax];
    for (NSInteger index = 0; index < kMax; ++index) {
        [array addObject:[NSValue valueWithRect:_dragRect[index]]];
    }
    
    self.dragRectArray = array;
}

- (void)setDebugMode:(int)mode
{
    debugMode = mode;
    [[self controlView] setNeedsDisplay:YES];
}

- (void)drawWithFrame:(NSRect)origCellFrame inView:(NSView *)controlView
{
    NSInteger highlight = debugMode & kShowHighlight;
    NSInteger dMode = debugMode & ~kShowHighlight;
    
    if (highlight) {
        [highlightColor set];
        NSBezierPath *hpath = [NSBezierPath bezierPathWithRect:borderRect];
        [hpath fill];
    }
    
    switch (dMode) {
        case kShowSelected:
            [selectedColor set];
            break;
            
        case kShowUnselected:
            [unselectedColor set];
            break;
            
        default:
                // don't even draw anything in any other state
            return;
    }
        // actual rect is "outset" by kHandleRadius points
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:borderRect];
    [path setLineWidth:0.0];
    [path stroke];
    
        // centered handles
    const NSInteger kMax = useDoubleHandles ? kDoubleHandleCount : kSimpleHandleCount;
    for (NSInteger index = 0; index < kMax; ++index) {
        [self fillOvalAt:_dragRect[index]];
    }
}

    // draw filled oval in given rect coordinates
- (NSRect)fillOvalAt:(NSRect)ovalRect
{
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:ovalRect];
    [path fill];
    return ovalRect;
}

    // no focus ring!
- (NSFocusRingType)focusRingType
{
    return NSFocusRingTypeNone;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
    NSPoint where = [controlView convertPoint:event.locationInWindow fromView:nil];
    
    const int kMax = useDoubleHandles ? kDoubleHandleCount : kSimpleHandleCount;
    
    for (int index = 0; index < kMax; ++index) {
        if (NSPointInRect(where, _dragRect[index])) {
            return NSCellHitTrackableArea;
        }
    }

    if (NSPointInRect(where, borderRect)) {
        NSUInteger value = NSCellHitContentArea;
        return value;
    }
    
    return NSCellHitNone;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
    const int kMax = useDoubleHandles ? kDoubleHandleCount : kSimpleHandleCount;
    for (int index = 0; index < kMax; ++index) {
        if (NSPointInRect(startPoint, _dragRect[index])) {
            dragIndex = index;
            inDrag = YES;
            dragStartPoint = startPoint;
            
            scale = 1.0;
            if ([controlView isKindOfClass:[CCESizableTextField class]]) {
                scale = [(CCESizableTextField *)controlView scale];
            }

//            NSLog(@"start at %@; area is %d; rect is %@", NSStringFromPoint(startPoint), index,
//                  NSStringFromRect(controlView.frame));
            return YES;
        }
    }

    return NO;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
    NSRect frame = [controlView frame];
    CGFloat diff;
    switch (dragIndex) {
        case kLeft:
            frame.origin.x += (diff = currentPoint.x - lastPoint.x);
            frame.size.width -= diff;
            break;
            
        case kRight:
            frame.size.width += currentPoint.x - lastPoint.x;
            break;
            
        case kTop:
            frame.size.height += currentPoint.y - lastPoint.y;
            break;
            
        case kBottom:
            frame.origin.y += (diff = currentPoint.y - lastPoint.y);
            frame.size.height -= diff;
            break;
            
        default:
            return NO;
    }
    
//    NSLog(@"drag to %@, rect is %@", NSStringFromPoint(currentPoint), NSStringFromRect(frame));
    [self reFrame:controlView at:frame];
    
    return YES;
}


- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
    if (flag) {
//        id target = self.target;
//        SEL action = self.action;
//        if (target && action) {
//            [(NSControl *)controlView sendAction:action to:target];
//        }
        NSRect frame = NSIntegralRect([controlView frame]);
//        NSLog(@"end at %@; rect is %@", NSStringFromPoint(lastPoint), NSStringFromRect(frame));
        [self reFrame:controlView at:frame];
    }
}

    // if control is modelled, reset model location to frame; otherwise, just call setFrame
    // Account for inset!
- (void)reFrame:(NSView *)controlView at:(NSRect)rect
{
    if ([controlView respondsToSelector:@selector(modelledControl)]) {
        CCEModelledControl *model = [(id)controlView modelledControl];
        CCELocation *location = (CCELocation *)[model location];
        if (location != nil) {
            rect = NSInsetRect(rect, kInsetPoints, kInsetPoints);
            NSRect modelRect = [NSView scaleRect:rect by:(1.0 / scale)];
//            NSLog(@"modelRect is %@", NSStringFromRect(modelRect));
            [location setRectValue:modelRect];
            return;
        }
    }
    
        // else
    [controlView setFrame:rect];
}

@end
