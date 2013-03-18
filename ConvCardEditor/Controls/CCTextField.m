//
//  CCTextField.m
//  CCardX
//
//  Created by Jim Hamilton on 8/23/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCTextField.m,v 1.3 2010/11/01 03:25:21 jimh Exp $
//
//  When field is scaled by setFrame:(NSRect)arect, also scales the font size

#import "CCTextField.h"
#import "AppDelegate.h"
#import "CommonStrings.h"
#import "CCEModelledControl.h"
#import "CCEManagedObjectModels.h"
#import "CCETextModel.h"
#import "CCELocation.h"
#import "NSControl+CCESetColorCode.h"
#import "CCELocationController.h"
#import "NSView+ScaleUtilities.h"
#import "fuzzyMath.h"

static NSInteger s_count;

static NSNumberFormatter *myNumFormatter = nil;

static NSInteger magicSuitCode = -1;
static BOOL typeMagicSuitSymbols = NO;

enum {
    kMagicSuitsByInit,
    kMagicSuitsByLessInitGreater
};

static NSCharacterSet *
suitTokenCharSet() {
    static NSCharacterSet *shared = nil;
    if (nil == shared) {
        NSMutableCharacterSet *mset = [[NSMutableCharacterSet alloc] init];
        [mset formUnionWithCharacterSet:[[NSCharacterSet letterCharacterSet] invertedSet]];
        
        shared = [mset copy];
    }
    
    return shared;
}

    // suits
static const char *kClubCharUTF8 = "\xe2\x99\xa3";
static const char *kDiamondCharUTF8 = "\xe2\x99\xa6";
static const char *kHeartCharUTF8 = "\xe2\x99\xa5";
static const char *kSpadeCharUTF8 = "\xe2\x99\xa0";

    // fractions
//static const char *kFracOneHalf = "\xc2\xbd";
//static const char *kFracOneThird = "\xe2\x85\x93";
//static const char *kFracTwoThirds = "\xe2\x85\x94";
//static const char *kFracOneQuarter = "\xc2\xbc";
//static const char *kFracThreeQuarters = "\xc2\xbe";

@interface CCTextField()

@property (readwrite) double scale;
@property double baseSize;
@property double baseFontSize;

@property NSString *fontKey;
@property NSString *fontName;

@property (readwrite) CGFloat lineHeight;
@property (readwrite) NSUInteger lineCount;

@property NSRect frameRect;

@property NSUInteger debugMode;

@property NSString *fieldName;

@property NSOperationQueue *opQ;
@property BOOL observesScaling;
@property NSMutableSet *scalingObservers;

+ (AppDelegate *)appDelegate;
+ (NSFont *)defaultFont;

- (void)watchColor:(NSString *)aColorKey;
- (void)unwatchColor;

- (void)watchFont:(NSString *)aFontKey;
- (void)unwatchFont;

- (void)setFont;

- (void)observeScaling;
- (void)stopObservingScaling;

@end

static NSFont *defaultFont;
static CGFloat defaultLineHeight;

@implementation CCTextField

@synthesize allOrNothing;

@synthesize modelledControl;
@synthesize locationController;

@synthesize scale;
@synthesize baseSize;
@synthesize baseFontSize;
@synthesize fontName;

@synthesize isNumber;
@synthesize fontKey;
@synthesize color;
@synthesize colorKey;

@synthesize frameRect;

@synthesize debugMode;

@synthesize isScaling;
@synthesize fieldName;
@synthesize opQ;

@synthesize font;
@synthesize lineHeight;
@synthesize lineCount;

@synthesize observesScaling;
@synthesize scalingObservers;

    // The data store always stores values as strings; NSTextField (this class' parent) will allow
    // a numeric value to be bound as an NSNumber value, which is a problem.  Adding the following
    // will force the value to be NSString, even for numeric values.
- (NSString *)valueBindingTransformerName
{
    return cceStringToStringTransformer;
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

+ (void)initialize {
    [self readMagic];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    defaultFont = [NSFont fontWithName:[ud stringForKey:ccDefaultFontName]
                                  size:[ud doubleForKey:ccDefaultFontSize]];
}

+ (void)readMagic
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    typeMagicSuitSymbols = [ud boolForKey:ccTypeMagicSuitSymbolsKey];
    magicSuitCode = [ud integerForKey:ccMagicSuitSymbolCodeKey];
}

+ (NSNumberFormatter *)numFormatter
{
    if (nil == myNumFormatter) {
        myNumFormatter = [[NSNumberFormatter alloc] init];
    }
    return myNumFormatter;
}

+ (AppDelegate *)appDel {
    return (AppDelegate *)[NSApp delegate];
}


+ (CCTextField *)textFieldFromModel:(CCETextModel *)model
{
    return [[self alloc] initWithTextModel:model];
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

- (void)setColorKey:(NSString *)aColorKey
{
    [self watchColor:aColorKey];
}

- (void) watchColor:(NSString *)aColorKey {
    [self unwatchColor];
    if (aColorKey) {
        colorKey = aColorKey;
        [[CCTextField appDel] addObserver:self
                               forKeyPath:colorKey 
                                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                  context:nil];
        [self setTextColor:[[CCTextField appDel] valueForKey:colorKey]];
    }
}
- (void)unwatchColor {
    if (colorKey) {
        [[CCTextField appDel] removeObserver:self forKeyPath:colorKey];
        
        colorKey = nil;
    }
}

- (void)setColor:(NSColor *)aColor
{
    [self unwatchColor];
    color = aColor;
    [self setTextColor:aColor];
}

- (void)watchFont:(NSString *)aFontKey {
    [self unwatchFont];
    if (aFontKey) {
        fontKey = aFontKey;
        AppDelegate *adel = [CCTextField appDel];
        [adel addObserver:self 
               forKeyPath:fontKey
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                  context:nil];
        
        NSFont *aFont = [adel valueForKey:aFontKey];
        baseFontSize = [aFont pointSize]; /// scale;
        [self setFont:aFont];
    } else {
        [self setFont:defaultFont];
    }
}
- (void)unwatchFont {
    if (fontKey) {
        [[CCTextField appDel] removeObserver:self forKeyPath:fontKey];
        
        fontKey = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (colorKey != nil && [keyPath isEqualToString:colorKey]) {
        [self setTextColor:[[CCTextField appDel] valueForKey:colorKey]];
    }
}

- (void)dealloc {
    [self unwatchColor];
    [self unwatchFont];
    
    [self stopObservingScaling];
    --s_count;
}

+ (NSInteger)count
{
    return s_count;
}

- (id)initWithFrame:(NSRect)frameR font:(NSString *)aFont fontSize:(CGFloat)fontSize {
    return [self initWithFrame:frameR font:aFont fontSize:(CGFloat)fontSize color:nil isNumber:NO];
}
- (id)initWithFrame:(NSRect)frameR font:(NSString *)aFont fontSize:(CGFloat)fontSize colorKey:(NSString *) aColor {
    return [self initWithFrame:frameR font:aFont fontSize:fontSize colorKey:aColor isNumber:NO];
}
- (id)initWithFrame:(NSRect)frameR font:(NSString *)aFont fontSize:(CGFloat)fontSize isNumber:(BOOL)isNum {
    return [self initWithFrame:frameR font:aFont fontSize:fontSize color:nil isNumber:isNum];
}
- (id)initWithFrame:(NSRect)frameR font:(NSString *)aFont fontSize:(CGFloat)fontSize color:(NSColor *)aColor {
    return [self initWithFrame:frameR font:aFont  fontSize:fontSize color:aColor isNumber:NO];
}
- (id)initWithFrame:(NSRect)frameR
               font:(NSString *)aFont
           fontSize:(CGFloat)fontSize
              color:(NSColor *)aColor
           isNumber:(BOOL)isNum {
    if (self = [self initWithFrame:frameR font:aFont fontSize:fontSize colorKey:nil isNumber:isNum]) {
        if (aColor) {
            [self setTextColor:aColor];
            color = aColor;
        }
    }
    
    return self;
}
    
- (id)initWithFrame:(NSRect)frameR
               font:(NSString *)aFontName
           fontSize:(CGFloat)fontSize
           colorKey:(NSString *)aColor
           isNumber:(BOOL)isNum {
    scale = [NSView defaultScale];
    
    frameR = [NSView scaleRect:frameR by:scale];
    if (self = [super initWithFrame:frameR]) {
        frameRect = frameR;
        baseSize = frameRect.size.width / scale;
        
        fontName = aFontName == nil ? defaultFont.fontName : aFontName;
        baseFontSize = fuzzyZero(fontSize) ? defaultFont.pointSize : fontSize;
        [self setFont];
        
        [self watchColor:aColor];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.0]];
        
        [self setBordered:NO];
        [self setEditable:YES];
        [self setSelectable:YES];
        [self setHidden:NO];
        
        [[self cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        
        isNumber = isNum;
        if (isNum) {
            [self setFormatter:[CCTextField numFormatter]];
            [self setAlignment:NSCenterTextAlignment];
        } else {
            [self setDelegate:self];    // allowing text manip while typing
        }
        
        [self setLineMetrics];

            // scaling
        opQ = [NSOperationQueue new];
        if (fieldName != nil) {
            [opQ setName:fieldName];
        }
        isScaling = NO;
        observesScaling = NO;
        ++s_count;
    }
    return self;
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
    if (newSuperview && !observesScaling) {
        [self observeScaling];
    } else {
        [self stopObservingScaling];
    }
}

- (id)initWithLocation:(CCELocation *)location
{
    return [self initWithLocation:location isNumber:NO];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum
{
    return [self initWithLocation:location isNumber:isNum colorCode:kNormalColor];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum colorCode:(NSInteger)colorCode
{
    NSPoint where = NSMakePoint([location.locX doubleValue], [location.locY doubleValue]);
    NSSize howBig = NSMakeSize([location.width doubleValue], [location.height doubleValue]);
    NSRect frameR = {where, howBig};
    
    return [self initWithFrame:frameR
                          font:nil
                      fontSize:0
                      colorKey:[[CCTextField appDel] colorKeyForCode:colorCode]
                      isNumber:isNum];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum color:(NSColor *)aColor
{
    NSPoint where = NSMakePoint([location.locX doubleValue], [location.locY doubleValue]);
    NSSize howBig = NSMakeSize([location.width doubleValue], [location.height doubleValue]);
    NSRect frameR = {where, howBig};
    
    return [self initWithFrame:frameR font:nil fontSize:0 color:aColor isNumber:isNum];
}

- (id)initWithTextModel:(CCETextModel *)model
{
    CCELocation *location = model.location;
    NSPoint where = NSMakePoint([location.locX doubleValue], [location.locY doubleValue]);
    NSSize howBig = NSMakeSize([location.width doubleValue], [location.height doubleValue]);
    NSRect frameR = {where, howBig};

    fontName = [[NSUserDefaults standardUserDefaults] valueForKey:ccDefaultFontName];
    double fontSize = [model.fontSize doubleValue];
    
    BOOL isNum = [model.numeric boolValue];
    
    fieldName = model.name;
    
    NSNumber *colorKeyObject = location.colorCode;
    if (colorKeyObject != nil) {
        NSString *myColorKey = [[CCTextField appDel] colorKeyForCode:[colorKeyObject integerValue]];
        self = [self initWithFrame:frameR font:fontName fontSize:fontSize colorKey:myColorKey isNumber:isNum];
    } else {
            // any nil (except alpha) kills color
        NSColor *myColor = nil;
        if (location.colorRed && location.colorGreen && location.colorBlue) {
            double alpha = 1.0;
            if (location.colorAlpha)
                alpha = [location.colorAlpha doubleValue];
            myColor = [NSColor colorWithCalibratedRed:[location.colorRed doubleValue]
                                                green:[location.colorGreen doubleValue]
                                                 blue:[location.colorBlue doubleValue]
                                                alpha:alpha];
        }
        self = [self initWithFrame:frameR font:fontName fontSize:fontSize color:color isNumber:isNum];
    }
    
    [self monitorModel:model];
    
    return self;
}

- (void)observeScaling
{
    observesScaling = YES;
    if (scalingObservers == nil) {
        scalingObservers = [NSMutableSet set];
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id observer;
    observer = [center addObserverForName:cceZoomFactorChanging
                                   object:nil
                                    queue:opQ
                               usingBlock:^(NSNotification *note) {
        if (note.object == self.window) {
            isScaling = YES;
        }
    }];
    [scalingObservers addObject:observer];
    
    observer = [center addObserverForName:cceZoomFactorChanged
                                   object:nil
                                    queue:opQ
                               usingBlock:^(NSNotification *note) {
        if (note.object == self.window) {
            isScaling = NO;
        }
    }];
    [scalingObservers addObject:observer];
}

- (void)stopObservingScaling
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [scalingObservers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [center removeObserver:obj];
    }];
    [scalingObservers removeAllObjects];
    observesScaling = NO;
}

- (NSUInteger)linesForHeight:(CGFloat)height
{
        // allow the next line if 4/5 or more is visible
    return MAX(fuzzyRound(height / lineHeight, 0, 0.8), 1.0);
}

+ (NSUInteger)linesForHeight:(CGFloat)height
{
    (void)[self defaultFont];
    return MAX(round(height / defaultLineHeight), 1.0);
}


- (void)setLineMetrics
{
    lineHeight = ([font ascender] - [font descender] + [font leading]) * scale;
    NSRect frame = self.frame;
    lineCount = [self linesForHeight:frame.size.height];
    if (lineCount < 1) {
        lineCount = 1;
    }
    [[self cell] setWraps:(lineCount > 1)];
}

- (void)setFont:(NSFont *)fontObj {
    font = fontObj;
    fontName = [fontObj fontName];
    [super setFont:[NSFont fontWithName:fontName size:baseFontSize * scale]];
    [self setLineMetrics];
}

- (void)setFontSize:(CGFloat)size
{
    baseFontSize = size;
    [self setFont];
}

- (void)setFont
{
    [self setFont:[NSFont fontWithName:fontName size:baseFontSize]];
}

- (void)setFrame:(NSRect)frameR
{
    [self setFrame:frameR forRescaling:isScaling];
}
- (void)setFrame:(NSRect)frameR forRescaling:(BOOL)rescaling
{
    frameRect = frameR;
    if (rescaling) {
        scale = frameRect.size.width / baseSize;
    } else {
        baseSize = frameRect.size.width / scale;
    }
    [super setFrame:frameRect];
    NSString *temp = [self stringValue];
    [self setStringValue:@""];
    [self setFont:[self font]];
    [self setStringValue:temp];
}

- (void)setTextColor:(NSColor *)newColor {
    if (nil == newColor)
        newColor = [[CCTextField appDel] normalColor];
    
    color = newColor;
    [super setTextColor:color];
}

- (void)setColorByCode:(NSInteger)code {
    NSColor *newColor = [[CCTextField appDel] colorForCode:code];
    
    [self setTextColor:newColor];
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification {
    NSDictionary *ui = [aNotification userInfo];
    NSTextView *editor = [ui objectForKey:@"NSFieldEditor"];
    if (editor) {
        if (allOrNothing) 
            [editor setSelectedRange:NSMakeRange(0, [[editor textStorage] length])];
    }
}

- (void)suitSubstitution:(NSTextView *)editor {
    switch (magicSuitCode) {
        case kMagicSuitsByInit:
        {
            NSArray *rgs = [editor selectedRanges];
            if ([rgs count] > 1) break;     // not a single range
            NSRange rg = [[rgs objectAtIndex:0] rangeValue];
            if (rg.length) break;           // not an insertion point
            if (rg.location < 2) break;     // not enough
            
            NSString *estr = [editor string];
            unichar c_one, c_two, c_three;
            
            c_one = [estr characterAtIndex:rg.location - 1];
            c_two = [estr characterAtIndex:rg.location - 2];
            BOOL rThree = rg.location > 2;
            if (rThree)
                c_three = [estr characterAtIndex:rg.location - 3];
            NSCharacterSet *set = suitTokenCharSet();
            if ([set characterIsMember:c_one] && (!rThree || [set characterIsMember:c_three])) {
                const char *replace = 0;
                switch (c_two) {
                    case 'C':
                        replace = kClubCharUTF8;
                        break;
                    case 'D':
                        replace = kDiamondCharUTF8;
                        break;
                    case 'H':
                        replace = kHeartCharUTF8;
                        break;
                    case 'S':
                        replace = kSpadeCharUTF8;
                        break;
                    default:
                        break;
                }
                if (replace) {
                    NSString *replStr = [NSString stringWithUTF8String:replace];
                    rg.location -= 2;
                    rg.length = 1;
                    [editor replaceCharactersInRange:rg withString:replStr];
                }
            }
            
            break;
        }
        case kMagicSuitsByLessInitGreater:
        {
            NSArray *rgs = [editor selectedRanges];
            if ([rgs count] > 1) break;     // not a single range
            NSRange rg = [[rgs objectAtIndex:0] rangeValue];
            if (rg.length) break;           // not an insertion point
            if (rg.location < 3) break;     // not enough
            
            NSString *estr = [editor string];
            unichar c_one, c_two, c_three;
            
            c_one = [estr characterAtIndex:rg.location - 1];
            c_two = [estr characterAtIndex:rg.location - 2];
            c_three = [estr characterAtIndex:rg.location - 3];
            NSLog(@"ding %c%c%c", c_one, c_two, c_three);
            if ('<' == c_three && '>' == c_one) {
                const char *replace = 0;
                switch (c_two) {
                    case 'C':
                    case 'c':
                        replace = kClubCharUTF8;
                        break;
                    case 'D':
                    case 'd':
                        replace = kDiamondCharUTF8;
                        break;
                    case 'H':
                    case 'h':
                        replace = kHeartCharUTF8;
                        break;
                    case 'S':
                    case 's':
                        replace = kSpadeCharUTF8;
                        break;
                    default:
                        break;
                }
                if (replace) {
                    NSString *replStr = [NSString stringWithUTF8String:replace];
                    rg.location -= 3;
                    rg.length = 3;
                    [editor replaceCharactersInRange:rg withString:replStr];
                }
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    NSDictionary *ui = [aNotification userInfo];
    NSTextView *editor = [ui objectForKey:@"NSFieldEditor"];
    if (editor) {
        if (typeMagicSuitSymbols)
            [self suitSubstitution:editor];
    }
}  

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
    
}

- (void)changeFont:(id)sender
{
    NSFont *oldFont = [self font];
    NSFont *newFont = [sender convertFont:oldFont];
    [self setFont:newFont];
    return;
}

- (BOOL)becomeFirstResponder {
    BOOL answer = [super becomeFirstResponder];
    
    [self scrollRectToVisible:[self bounds]];
    
    id myWin = [self window].delegate;
    if ([myWin respondsToSelector:@selector(registerFirstResponder:)]) {
        [myWin performSelector:@selector(registerFirstResponder:)withObject:self];
    }
    
    return answer;
}

- (BOOL)resignFirstResponder
{
    BOOL answer = [super resignFirstResponder];
    
    id myWin = [self window].delegate;
    if ([myWin respondsToSelector:@selector(unregisterFirstResponder:)]) {
        [myWin performSelector:@selector(unregisterFirstResponder:) withObject:self];
    }
    
    return answer;
}

- (BOOL)isNumberField
{
    return isNumber;
}
- (void)setNumberField:(BOOL)numberField
{
    if (isNumber == numberField)
        return;
    
    isNumber = numberField;
    if (isNumber) {
        [self setFormatter:[[self class] numFormatter]];
        [self setAlignment:NSCenterTextAlignment];
        [self setDelegate:nil];
    } else {
        [self setFormatter:nil];
        [self setAlignment:NSLeftTextAlignment];
        [self setDelegate:self];
    }
    
    [self setStringValue:@""];
}

- (NSString *)description
{
    NSString *start = [NSString stringWithFormat:@"%@ value '%@' \n\tframe: %@\n\tbounds: %@",
                       self.class, self.stringValue,
                       NSStringFromRect(self.frame), NSStringFromRect(self.bounds)];
    return start;
}

#pragma mark DEBUGGING

- (void)mouseDown:(NSEvent *)theEvent
{
    [CCDebuggableControlEnable logIfWanted:theEvent inView:self];
    [super mouseDown:theEvent];
}
- (void)mouseUp:(NSEvent *)theEvent
{
    [CCDebuggableControlEnable logIfWanted:theEvent inView:self];
    [super mouseUp:theEvent];
}

@end
