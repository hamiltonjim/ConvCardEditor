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

@property double baseSize;
@property double baseFontSize;

@property NSString *fontKey;
@property NSString *fontName;

@property NSRect frameRect;

@property NSUInteger debugMode;

- (void) watchColor:(NSString *)aColorKey;
- (void) unwatchColor;

- (void) watchFont:(NSString *)aFontKey;
- (void) unwatchFont;

@end

static NSFont *defaultFont;

@implementation CCTextField

@synthesize allOrNothing;

@synthesize modelledControl;
@synthesize locationController;

@synthesize baseSize;
@synthesize baseFontSize;
@synthesize fontName;

@synthesize isNumber;
@synthesize fontKey;
@synthesize color;
@synthesize colorKey;

@synthesize frameRect;

@synthesize debugMode;

+ (void) initialize {
    [self readMagic];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    defaultFont = [NSFont fontWithName:[ud stringForKey:ccDefaultFontName]
                                  size:[ud doubleForKey:ccDefaultFontSize]];
}

+ (void) readMagic {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    typeMagicSuitSymbols = [ud boolForKey:ccTypeMagicSuitSymbolsKey];
    magicSuitCode = [ud integerForKey:ccMagicSuitSymbolCodeKey];
}

+ (NSNumberFormatter *) numFormatter {
    if (nil == myNumFormatter) {
        myNumFormatter = [[NSNumberFormatter alloc] init];
    }
    return myNumFormatter;
}

+ (AppDelegate *) appDel {
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
- (void) unwatchColor {
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

- (void) watchFont:(NSString *)aFontKey {
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
- (void) unwatchFont {
    if (fontKey) {
        [[CCTextField appDel] removeObserver:self forKeyPath:fontKey];
        
        fontKey = nil;
    }
}

- (void) dealloc {
    [self unwatchColor];
    [self unwatchFont];
}

- (id) initWithFrame:(NSRect)frameR font:(NSString *)aFont {
    return [self initWithFrame:frameR font:aFont color:nil isNumber:NO];
}
- (id) initWithFrame:(NSRect)frameR font:(NSString *)aFont colorKey:(NSString *) aColor {
    return [self initWithFrame:frameR font:aFont colorKey:aColor isNumber:NO];
}
- (id) initWithFrame:(NSRect)frameR font:(NSString *)aFont isNumber:(BOOL)isNum {
    return [self initWithFrame:frameR font:aFont color:nil isNumber:isNum];
}
- (id) initWithFrame:(NSRect)frameR font:(NSString *)aFont color:(NSColor *)aColor {
    return [self initWithFrame:frameR font:aFont color:aColor isNumber:NO];
}
- (id) initWithFrame:(NSRect)frameR
                font:(NSString *)aFont 
               color:(NSColor *)aColor
            isNumber:(BOOL)isNum {
    if (self = [self initWithFrame:frameR font:aFont colorKey:nil isNumber:isNum]) {
        if (aColor) {
            [self setTextColor:aColor];
            color = aColor;
        }
    }
    
    return self;
}
    
- (id) initWithFrame:(NSRect)frameR
                font:(NSString *)aFontKey 
            colorKey:(NSString *)aColor
            isNumber:(BOOL)isNum {
        
    if (self = [super initWithFrame:frameR]) {
        frameRect = frameR;
        baseSize = frameRect.size.width;
        
        [self watchFont:aFontKey];
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

    }
    return self;
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
                      colorKey:[[CCTextField appDel] colorKeyForCode:colorCode]
                      isNumber:isNum];
}

- (id)initWithLocation:(CCELocation *)location isNumber:(BOOL)isNum color:(NSColor *)aColor
{
    NSPoint where = NSMakePoint([location.locX doubleValue], [location.locY doubleValue]);
    NSSize howBig = NSMakeSize([location.width doubleValue], [location.height doubleValue]);
    NSRect frameR = {where, howBig};
    
    return [self initWithFrame:frameR font:nil color:aColor isNumber:isNum];
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
    
    NSNumber *colorKeyObject = location.colorCode;
    if (colorKeyObject != nil) {
        NSString *myColorKey = [[CCTextField appDel] colorKeyForCode:[colorKeyObject integerValue]];
        self = [self initWithFrame:frameR font:fontName colorKey:myColorKey isNumber:isNum];
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
        self = [self initWithFrame:frameR font:fontName color:color isNumber:isNum];
    }
    
    self.baseFontSize = fontSize;
    [self monitorModel:model];
    
    return self;
}

- (void) setFont:(NSFont *)fontObj {
    fontName = [fontObj fontName];
    [super setFont:[NSFont fontWithName:fontName size:baseFontSize]];
}

- (void)setFontSize:(CGFloat)size
{
    baseFontSize = size;
    [super setFont:[NSFont fontWithName:fontName size:baseFontSize]];
}

- (void) setFrame:(NSRect)frameR {
    frameRect = frameR;
    [super setFrame:frameRect];
    NSString *temp = [self stringValue];
    [self setStringValue:@""];
    [self setFont:[self font]];
    [self setStringValue:temp];
}

- (void) setTextColor:(NSColor *)newColor {
    if (nil == newColor)
        newColor = [[CCTextField appDel] normalColor];
    
    color = newColor;
    [super setTextColor:color];
}

- (void) setColorByCode:(NSInteger)code {
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

- (void) suitSubstitution:(NSTextView *)editor {
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

- (BOOL) becomeFirstResponder {
    BOOL answer = [super becomeFirstResponder];
    
    [self scrollRectToVisible:[self bounds]];
    
    return answer;
}

@end
