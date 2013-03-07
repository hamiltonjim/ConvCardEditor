//
//  CommonStrings.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CommonStrings.h"

NSString *ccDefaultFontName = @"FontName";
NSString *ccDefaultFontSize = @"FontSize";

NSString *ccDefaultScale = @"DefaultScale";

NSString *ccAlertColor = @"alertColor";
NSString *ccAnnounceColor = @"announceColor";
NSString *ccNormalColor = @"normalColor";

    // dimensions
NSString *ccDimensionUnit = @"dimensionUnits";
NSString *ccUnitPoints = @"points";
NSString *ccUnitInches = @"in";
NSString *ccUnitCentimeters = @"cm";

const double kInchDivisor = 72.0;
const double kInchesToCentimeters = 2.54;
const double kCentimeterDivisor = kInchDivisor / kInchesToCentimeters;

NSString *ccScaleFontChooser = @"scaleFontChooser";

NSString *ccCheckboxDrawStyle = @"checkBoxDrawStyle";

NSString *ccLeadCircleStrokeWidth = @"leadCircleStrokeWidth";
NSString *ccLeadCircleColorKey = @"leadCircleColor";

    // keys for typing suit symbols
NSString *ccTypeMagicSuitSymbolsKey = @"typeMagicSuitSymbols";
NSString *ccMagicSuitSymbolCodeKey = @"magicSuitSymbolCode";

NSString *keyControlDebugging = @"controlDebugging";

NSString *ccChecksAreSquare = @"ChecksAreSquare";
NSString *ccCheckboxWidth = @"checkboxWidth";
NSString *ccCheckboxHeight = @"checkboxHeight";

NSString *ccCirclesAreRound = @"CirclesAreRound";
NSString *ccCircleWidth = @"circleWidth";
NSString *ccCircleHeight = @"circleHeight";

    // managed object entities
NSString *ccSingleCheck = @"SingleCheck";
NSString *ccMultiCheck = @"MultiCheck";
NSString *ccText = @"Text";

NSString *ccLocation = @"Location";
NSString *ccCardType = @"CardType";
NSString *ccSetting = @"Setting";

    // keys for location of control models
NSString *ccModelLocation = @"location";
NSString *ccModelMultiLocations = @"locations";

const double SCALE_MULT = 1.0;

    // scale
NSString *cceMaximumScale = @"MaximumScale";
NSString *cceMinimumScale = @"MinimumScale";

    // scale changing
NSString *cceZoomFactorChanging = @"ZoomFactorChanging";
NSString *cceZoomFactorChanged = @"ZoomFactorChanged";
NSString *cceZoomFactor = @"ZoomFactor";

NSString *kControlLocationX = @"locX";
NSString *kControlLocationY = @"locY";
NSString *kControlWidth = @"width";
NSString *kControlHeight = @"height";

NSString *cceLocationColor = @"color";
NSString *cceLocationColorCode = @"colorCode";

NSString *cceLocationIndex = @"index";

NSString *cceGridState = @"gridState";

NSString *cceStepTransformer = @"CCEStepIncrementTransformer";
NSString *cceStepIncrement = @"stepIncrement";
NSString *cceStepIncrementIndex = @"stepIncrementIndex";

NSString *applicationDomain = @"com.shokwave.ConvCardEditor";

NSString *errorNotify = @"errorNotify";

@implementation CommonStrings

+ (void)initialize
{
    if (self == [CommonStrings class]) {
            // internationalize user-visible strings
        ccUnitPoints = NSLocalizedString(@"points", @"points unit name");
        ccUnitInches = NSLocalizedString(@"in", @"inches unit name");
        ccUnitCentimeters = NSLocalizedString(@"cm", @"centimeters unit name");
    }
}

+ (NSArray *)dimensionKeys
{
    return @[kControlLocationX, kControlLocationY, kControlWidth, kControlHeight];
}

+ (NSString *)standardColorKey:(int)colorCode
{
    NSString *key;
    switch (colorCode) {
        case kNormalColor:
            key = ccNormalColor;
            break;
            
        case kAlertColor:
            key = ccAlertColor;
            break;
            
        case kAnnounceColor:
            key = ccAnnounceColor;
            break;
            
        default:
            key = nil;
            break;
    }
    
    return key;
}

+ (NSInteger)standardColorCodeForKey:(NSString *)theKey
{
    NSInteger code = -1;
    
    if ([ccNormalColor isEqualToString:theKey]) {
        code = kNormalColor;
    } else if ([ccAlertColor isEqualToString:theKey]) {
        code = kAlertColor;
    } else if ([ccAnnounceColor isEqualToString:theKey]) {
        code = kAnnounceColor;
    }
    
    return code;
}

@end
