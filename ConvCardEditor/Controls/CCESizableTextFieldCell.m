//
//  CCESizableTextFieldCell.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/24/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCESizableTextFieldCell.h"
#import "CommonStrings.h"

const CGFloat kHandleRadius = 2.0;
const CGFloat kHandleDiameter = kHandleRadius * 2.0;

static NSFont *defaultFont;
static CGFloat defaultLineHeight;

@interface CCESizableTextFieldCell ()

@property NSRect textRect;
@property NSRect borderRect;

+ (NSFont *)defaultFont;

- (NSRect)fillOvalAt:(NSRect)ovalRect;

- (NSRect)dotRectAroundX:(CGFloat)x y:(CGFloat)y;

@end

@implementation CCESizableTextFieldCell

@synthesize textRect;
@synthesize borderRect;
@synthesize useDoubleHandles;
@synthesize font;
@synthesize lineHeight;
@synthesize lineCount;
@synthesize frameColor;

+ (NSFont *)defaultFont
{
    if (defaultFont == nil) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        defaultFont = [NSFont fontWithName:[ud stringForKey:ccDefaultFontName]
                                      size:[ud doubleForKey:ccDefaultFontSize]];
        defaultLineHeight = [defaultFont ascender] - [defaultFont descender] + [defaultFont leading];
    }
    
    return defaultFont;
}
+ (void)setDefaultFont:(NSFont *)font
{
    defaultFont = font;
    defaultLineHeight = [defaultFont ascender] - [defaultFont descender] + [defaultFont leading];
}

- (id)initTextCell:(NSString *)aString
{
    if ((self = [super initTextCell:aString])) {
        [self sendActionOn:NSLeftMouseUpMask];
    }
    
    return self;
}

- (id)initImageCell:(NSImage *)image
{
    if ((self = [super initImageCell:image])) {
        [self sendActionOn:NSLeftMouseUpMask];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self sendActionOn:NSLeftMouseUpMask];
    }
    return self;
}

- (void)setFont:(NSFont *)aFont
{
    font = aFont;
    
        // calculate line height
    if (font != nil) {
        self.lineHeight = [font ascender] - [font descender] + [font leading];
    }
}
- (NSFont *)font
{
    if (font == nil)
        font = [[self class] defaultFont];
    return font;
}

- (NSRect)dotRectAroundX:(CGFloat)x y:(CGFloat)y
{
    return NSMakeRect(x - kHandleRadius, y - kHandleRadius, kHandleDiameter, kHandleDiameter);
}

- (void)calcDrawInfo:(NSRect)aRect
{
    textRect = NSInsetRect(aRect, kHandleDiameter, kHandleDiameter);
    
    borderRect = NSInsetRect(aRect, kHandleRadius, kHandleRadius);
    
    rect[kLeft] = [self dotRectAroundX:NSMinX(borderRect) y:NSMidY(borderRect)];
    rect[kRight] = [self dotRectAroundX:NSMaxX(borderRect) y:NSMidY(borderRect)];
    
    rect[kTop] = [self dotRectAroundX:NSMidX(borderRect) y:NSMaxY(borderRect)];
    rect[kBottom] = [self dotRectAroundX:NSMidX(borderRect) y:NSMinY(borderRect)];
    
    rect[kBottomLeft] = [self dotRectAroundX:NSMinX(borderRect) y:NSMinY(borderRect)];
    rect[kBottomRight] = [self dotRectAroundX:NSMaxX(borderRect) y:NSMinY(borderRect)];
    rect[kTopLeft] = [self dotRectAroundX:NSMinX(borderRect) y:NSMaxY(borderRect)];
    rect[kTopRight] = [self dotRectAroundX:NSMaxX(borderRect) y:NSMaxY(borderRect)];
}

- (void)drawWithFrame:(NSRect)origCellFrame inView:(NSView *)controlView
{
    if (frameColor == nil) {
        frameColor = [NSColor blackColor];
    }
    
        // actual rect is "outset" by kHandleRadius points
    [frameColor set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:borderRect];
    [path setLineWidth:0.0];
    [path stroke];
    
        // centered handles
    const int kMax = useDoubleHandles ? kDoubleHandleCount : kSimpleHandleCount;
    
    for (int index = 0; index < kMax; ++index) {
        [self fillOvalAt:rect[index]];
    }
}

    // draw filled oval in given rect coordinates
- (NSRect)fillOvalAt:(NSRect)ovalRect
{
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:ovalRect];
    [path fill];
    return ovalRect;
}

- (NSUInteger)linesForHeight:(CGFloat)height
{
    return MIN(round(height / lineHeight), 1.0);
}

+ (NSUInteger)linesForHeight:(CGFloat)height
{
    (void)[self defaultFont];
    return MIN(round(height / defaultLineHeight), 1.0);
}

    // no focus ring!
- (NSFocusRingType)focusRingType
{
    return NSFocusRingTypeNone;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
    NSPoint where = [controlView convertPoint:event.locationInWindow fromView:nil];
    
    if (NSPointInRect(where, textRect)) {
        NSUInteger value = NSCellHitContentArea;
        if ([self isEditable])
            value |= NSCellHitEditableTextArea;
        NSLog(@"hitTestForEvent %ld", value);
        return value;
    }
    
    const int kMax = useDoubleHandles ? kDoubleHandleCount : kSimpleHandleCount;
    
    for (int index = 0; index < kMax; ++index) {
        if (NSPointInRect(where, rect[index])) {
            NSLog(@"hitTestForEvent %d", NSCellHitTrackableArea);
            return NSCellHitTrackableArea;
        }
    }

    return NSCellHitNone;
}

//- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
//{
//    if (flag) {
//        id target = [self target];
//        SEL action = [self action];
//        if (target && action) {
//            [target performSelector:action withObject:controlView];
//        }
//    }
//}
//

@end
