//
//  CommonStrings.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

/* colors */
#define ALERT_COLOR_R       0.8
#define ALERT_COLOR_G       0.0
#define ALERT_COLOR_B       0.0

#define ANNOUNCE_COLOR_R    0.0
#define ANNOUNCE_COLOR_G    0.580392156862745
#define ANNOUNCE_COLOR_B    0.945098039215686

/*  LAYOUT colors */
#define UNSELECTED_COLOR_R  0.0
#define UNSELECTED_COLOR_G  0.25
#define UNSELECTED_COLOR_B  1.0
#define UNSELECTED_COLOR_A  0.3

#define SELECTED_COLOR_R    1.0
#define SELECTED_COLOR_G    0.5
#define SELECTED_COLOR_B    0.0
#define SELECTED_COLOR_A    0.7

#define SELECTED_OTHER_CL_R 1.0
#define SELECTED_OTHER_CL_G 0.0
#define SELECTED_OTHER_CL_B 0.8
#define SELECTED_OTHER_CL_A 0.4

#define HIGHLIGHT_COLOR_R   1.0
#define HIGHLIGHT_COLOR_G   1.0
#define HIGHLIGHT_COLOR_B   0.1
#define HIGHLIGHT_COLOR_A   0.5

enum kAlertingColor {
    kStandardColorsLowerBound,
    
    kNormalColor = kStandardColorsLowerBound,
    kAlertColor,
    kAnnounceColor,
    
        // final entry: number of "real" entries
    kNumberStandardColors
    };

extern NSString *ccDefaultFontSize;
extern NSString *ccDefaultFontName;
extern NSString *ccDefaultScale;

extern NSString *ccAlertColor;
extern NSString *ccAnnounceColor;
extern NSString *ccNormalColor;

    // dimensions
extern NSString *ccDimensionUnit;

enum kDimensionUnits {
    kPointsDimension = 0,
    kInchesDimension,
    kCentimetersDimension
    };
extern NSString *ccUnitPoints;
extern NSString *ccUnitInches;
extern NSString *ccUnitCentimeters;


extern const double kInchDivisor;
extern const double kInchesToCentimeters;
extern const double kCentimeterDivisor;

extern NSString *ccCheckboxDrawStyle;
extern NSString *ccLeadCircleStrokeWidth;
extern NSString *ccLeadCircleColorKey;

extern NSString *ccTypeMagicSuitSymbolsKey;
extern NSString *ccMagicSuitSymbolCodeKey;

extern NSString *ccChecksAreSquare;
extern NSString *ccCheckboxWidth;
extern NSString *ccCheckboxHeight;  // not used when AreSquare

extern NSString *ccCirclesAreRound;
extern NSString *ccCircleWidth;
extern NSString *ccCircleHeight;    // not used when AreRound

    // managed object entities
extern NSString *ccSingleCheck;
extern NSString *ccMultiCheck;
extern NSString *ccText;

    // control types chooser
enum EControlType {
    kPointerControl = 0,
    kTextControl = 100,
    kSingleCheckboxControl = 200,
    kMultiCheckboxControl = 300,
    kCircleChoiceControl = 400,
    
        // mostly for adding children to an existing control
    kControlVariant = 10,
    kTagGap = 100
};

extern NSString *ccLocation;
extern NSString *ccCardType;
extern NSString *ccSetting;

extern NSString *ccModelLocation;
extern NSString *ccModelMultiLocations;

extern const double SCALE_MULT;

extern NSString *kControlLocationX;
extern NSString *kControlLocationY;
extern NSString *kControlWidth;
extern NSString *kControlHeight;

extern NSString *cceLocationColor;
extern NSString *cceLocationColorCode;

extern NSString *cceLocationIndex;

extern NSString *cceGridState;

extern NSString *cceZoomFactorChanging;
extern NSString *cceZoomFactorChanged;
extern NSString *cceZoomFactor;

extern NSString *cceMaximumScale;
extern NSString *cceMinimumScale;

    // preference for step value
extern NSString *cceStepTransformer;
extern NSString *cceStepIncrement;
extern NSString *cceStepIncrementIndex;

extern NSString *errorNotify;

extern NSString *cceEnableDebugging;

enum EStepRadioChoices {
    kStepRadioOne = 0,
    kStepRadioHalf,
    kStepRadioOther
};

extern NSString *applicationDomain;


@interface CommonStrings : NSObject

+ (NSString *)standardColorKey:(int)colorCode;
+ (NSInteger)standardColorCodeForKey:(NSString *)theKey;
+ (NSArray *)dimensionKeys;

@end
