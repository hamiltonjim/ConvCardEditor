//
//  CCESizableTextField.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/24/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCESizableTextField.h"
#import "CommonStrings.h"
#import "CCELocation.h"
#import "CCETextModel.h"
#import "AppDelegate.h"
#import "NSControl+CCESetColorCode.h"
#import "fuzzyMath.h"
#import "CCELocationController.h"
#import "NSView+ScaleUtilities.h"

static NSInteger s_count;

/*
    Creates a rect with the two given points as opposite corners.
    It doesn't matter whether the corners are top-right and bottom-left
    or top-left and bottom-right, or which is which
 */
NSRect JFH_RectFromPoints(NSPoint p1, NSPoint p2)
{
    NSPoint origin;
    origin.x = MIN(p1.x, p2.x);
    origin.y = MIN(p1.y, p2.y);
    
    NSSize size;
    size.width = p1.x - p2.x;
    if (size.width < 0)
        size.width = -size.width;
    
    size.height = p1.y - p2.y;
    if (size.height < 0)
        size.height = -size.height;
    
    NSRect answer;
    answer.origin = origin;
    answer.size = size;
    
    return answer;
}

static NSString *loremIpsum;

static NSFont *defaultFont;
static CGFloat defaultLineHeight;

@interface CCESizableTextField ()

@property (readwrite) CGFloat lineHeight;
@property (readwrite) NSUInteger lineCount;

@property NSRect borderRect;
@property (nonatomic) int debugMode;

@property (readwrite) NSUInteger clickCount;

@property NSUInteger testingIndex;

+ (AppDelegate *)appDelegate;
+ (NSFont *)defaultFont;

- (void)contentInit;

    // relay the action from the subview
- (void)relay:(id)sender;

@end

@implementation CCESizableTextField

@synthesize insideTextField;

@synthesize borderRect;
@synthesize useDoubleHandles;
@synthesize frameColor;

@synthesize modelledControl;
@synthesize locationController;

+ (Class)cellClass
{
    return [CCESizableTextFieldCell class];
}

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[NSApp delegate];
}

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

+ (void)initialize
{
    if (self == [CCESizableTextField class]) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"loremipsum" withExtension:@"text"];
        loremIpsum = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    }
}

+ (CCESizableTextField *)textFieldFromModel:(CCETextModel *)model
{
    return [[CCESizableTextField alloc] initWithTextModel:model];
}

- (void)dealloc
{
    --s_count;
}

+ (NSInteger)count
{
    return s_count;
}

- (id)monitorModel:(CCEModelledControl *)model
{
    modelledControl = model;
    
        // monitoring
    locationController = [[CCELocationController alloc] initWithModel:model control:self];
    
    return locationController;
}

- (void)stopMonitoring
{
    if (locationController != nil &&
        [locationController respondsToSelector:@selector(stopMonitoringLocation)]) {
        [locationController stopMonitoringLocation];
    }
    locationController = nil;
}

    // the sizable version is larger by 4 points in each dimension
    // (delegated to cell class)
- (NSPoint)insetModelledRect
{
    return [CCESizableTextFieldCell insetSize];
}

- (CCESizableTextFieldCell *)cell
{
    return (CCESizableTextFieldCell *)[super cell];
}

- (void)contentInit
{
    useDoubleHandles = NO;
    [[insideTextField cell] setPlaceholderString:loremIpsum];
    [self setStringValue:@""];
    [self calcSize];
    [[self cell] sendActionOn:NSLeftMouseUpMask];
    
    [self setFont:[[self class] defaultFont]];
}

- (void)setStringValue:(NSString *)aString
{
    [insideTextField setStringValue:aString];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self resetCursorRects];
}

- (void)resetCursorRects
{
    [self calcSize];
    
    NSArray *rectArray = [[self cell] dragRectArray];
    [rectArray enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        NSRect rect = [obj rectValue];
        [self addCursorRect:rect cursor:[NSCursor crosshairCursor]];
    }];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
        // deep scaling is done recursively, no need to handle subviews here
    if (insideTextField.isScaling) {
        return;
    }
    
    const NSUInteger xbits = NSViewMinXMargin | NSViewWidthSizable | NSViewMaxXMargin;
    const NSUInteger ybits = NSViewMinYMargin | NSViewHeightSizable | NSViewMaxYMargin;
    
    NSSize newSize = [self frame].size;
    CGFloat xDiff = newSize.width - oldSize.width;
    CGFloat yDiff = newSize.height - oldSize.height;
    
        // short-circuit test
    if (fuzzyZero(xDiff) && fuzzyZero(yDiff)) {
        return;
    }
    
    NSUInteger mask = [self autoresizingMask];
    
        // how many parts get sized (in each direction)?
    xDiff /= count1bits(xbits & mask);
    yDiff /= count1bits(ybits & mask);
    
    [[self subviews] enumerateObjectsUsingBlock:^(NSView *obj, NSUInteger idx, BOOL *stop) {
        NSRect frame = [obj frame];
        if (mask & NSViewMinXMargin)
            frame.origin.x += xDiff;
        if (mask & NSViewWidthSizable)
            frame.size.width += xDiff;
        
        if (mask & NSViewMinYMargin)
            frame.origin.y += yDiff;
        if (mask & NSViewHeightSizable)
            frame.size.height += yDiff;
        
            // nothing needs to be done for Max[XY]Margin...
        
        [obj setFrame:frame];
    }];
}

- (void)relay:(id)sender
{
    [self sendAction:[self action] to:[self target]];
}

    // designated initializer
- (id)initWithFrame:(NSRect)frRect
           isNumber:(BOOL)isNum
          colorName:(NSString *)colorName
              color:(NSColor *)color
               font:(NSString *)fontName
           fontSize:(CGFloat)fontSize
{
        // frRect is the frame of the inside text field; actual control is outside...
    NSPoint inset = [self insetModelledRect];
    NSRect outsideRect = NSInsetRect(frRect, -inset.x, -inset.y);
    
        // inside rect relative to outside rect:
    NSRect insideRect = NSMakeRect(inset.x, inset.y, frRect.size.width, frRect.size.height);
    
    outsideRect = [NSView defaultScaleRect:outsideRect];
        // super init with scaled rect
    if ((self = [super initWithFrame:outsideRect]) != nil) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (fontSize < 0.5) {
            fontSize = [ud doubleForKey:ccDefaultFontSize];
        }
        
        if (colorName == nil && color == nil) {
            colorName = ccNormalColor;
        }
        
        if (colorName == nil) {
            insideTextField = [[CCTextField alloc] initWithFrame:insideRect
                                                            font:fontName
                                                        fontSize:fontSize
                                                           color:color
                                                        isNumber:isNum];
        } else {
            insideTextField = [[CCTextField alloc] initWithFrame:insideRect
                                                            font:fontName
                                                        fontSize:fontSize
                                                        colorKey:colorName
                                                        isNumber:isNum];
        }
        
        [insideTextField setRefusesFirstResponder:YES];
        [[insideTextField cell] setFocusRingType:NSFocusRingTypeNone];
        [insideTextField setEnabled:NO];
        [insideTextField setEditable:NO];
        
        [insideTextField sendActionOn:NSLeftMouseUpMask];
        
        [self addSubview:insideTextField];
        
//        NSButton *transparentButton = [[NSButton alloc] initWithFrame:insideRect];
//        [transparentButton setTransparent:YES];
//        [transparentButton setTarget:self];
//        [transparentButton setAction:@selector(relay:)];
//        [self addSubview:transparentButton];
        
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self contentInit];
        
        ++s_count;
    }
    
    return self;
}

- (id)initWithLocation:(CCELocation *)location
{
    return [self initWithFrame:[location rectValue]
                      isNumber:NO
                     colorName:nil
                         color:nil
                          font:nil
                      fontSize:0.0];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum
{
    return [self initWithFrame:[location rectValue]
                      isNumber:isNum
                     colorName:nil
                         color:nil
                          font:nil
                      fontSize:0.0];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum colorCode:(NSInteger)colorCode
{
    NSString *colorKey = [[CCESizableTextField appDelegate] colorKeyForCode:colorCode];
    return [self initWithFrame:[location rectValue]
                      isNumber:isNum
                     colorName:colorKey
                         color:nil
                          font:nil
                      fontSize:0.0];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum colorKey:(NSString *)colorKey
{
    return [self initWithFrame:[location rectValue]
                      isNumber:isNum
                     colorName:colorKey
                         color:nil
                          font:nil
                      fontSize:0.0];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum color:(NSColor *)aColor
{
    return [self initWithFrame:[location rectValue]
                      isNumber:isNum
                     colorName:nil
                         color:aColor
                          font:nil
                      fontSize:0.0];
}

- (id)initWithTextModel:(CCETextModel *)model
{
    CCELocation *location = model.location;
    NSNumber *colorCode = location.colorCode;
    NSString *colorKey = model == nil ? nil : [[CCESizableTextField appDelegate] colorKeyForCode:[colorCode doubleValue]];
    NSColor *aColor = nil;
    if (colorKey == nil) {
        aColor = model.location.color;
    }
    
    if (self = [self initWithFrame:[location rectValue]
                          isNumber:[model.numeric boolValue]
                         colorName:colorKey
                             color:aColor
                              font:nil
                          fontSize:[model.fontSize doubleValue]]) {
        [self monitorModel:model];
    }
    
    return self;
}

- (CGFloat)scale
{
    return [insideTextField scale];
}

- (void)setDebugMode:(int)debugMode
{
    CCESizableTextFieldCell *cell = [self cell];
    [cell setDebugMode:debugMode];
}

#pragma mark DRAWING

- (NSUInteger)linesForHeight:(CGFloat)height
{
    return [insideTextField linesForHeight:height];
}

+ (NSUInteger)linesForHeight:(CGFloat)height
{
    return [CCTextField linesForHeight:height];
}

    // no focus ring!
- (NSFocusRingType)focusRingType
{
    return NSFocusRingTypeNone;
}

#pragma mark COLOR
    // delegated to inside text control
- (void)setColor:(NSColor *)aColor
{
    [insideTextField setColor:aColor];
}
- (NSColor *)color
{
    return [insideTextField color];
}

- (void)setColorKey:(NSString *)aColorKey
{
    [insideTextField setColorKey:aColorKey];
}
- (NSString *)colorKey
{
    return [insideTextField colorKey];
}

- (BOOL)isPointInsideMe:(NSPoint)aPoint
{
    return NSPointInRect(aPoint, insideTextField.frame);
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

#pragma mark NUMERIC or ANY TEXT

    // just pass thru to inner control...
- (BOOL)isNumberField
{
    return insideTextField.isNumber;
}
- (void)setNumberField:(BOOL)numberField
{
    [insideTextField setNumberField:numberField];
}

#pragma mark FONTS

- (void)setFont:(NSFont *)aFont
{
    [insideTextField setFont:aFont];
}

#pragma mark TESTING

- (void)advanceTest
{
    if (insideTextField.isNumber) {
        NSInteger val = [insideTextField integerValue];
        if (val >= 40)
            val = -1;
        [insideTextField setIntegerValue:++val];
    } else {
        static NSString *strings[] = {
            @"",
            @"This is a test!",
            @"Testing too",
            @"Why not try",
            @"Something new",
            @"Burma Shave",
            @"Plus, one really really really really really really long string, to test whether the control wraps or truncates"
        };
        static const int kNumStrs = sizeof strings / sizeof strings[0];
        
            // note: _testingIndex is any random garbage; the only important thing is its value modulo kNumStrs
        NSUInteger index = _testingIndex++ % kNumStrs;
        [insideTextField setStringValue:strings[index]];
    }
}

- (void)resetTest
{
    [insideTextField setStringValue:@""];
}

#pragma mark DEBUGGING

- (void)mouseDown:(NSEvent *)theEvent
{
    _clickCount = theEvent.clickCount;
    [CCDebuggableControlEnable logIfWanted:theEvent inView:self];
    [super mouseDown:theEvent];
}
- (void)mouseUp:(NSEvent *)theEvent
{
    [CCDebuggableControlEnable logIfWanted:theEvent inView:self];
    [super mouseUp:theEvent];
}

@end
