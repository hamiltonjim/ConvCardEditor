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


extern NSString *ccDefaultFont;
extern NSString *ccDefaultNamesFont;
extern NSString *ccDefaultScale;

extern NSString *ccAlertColor;
extern NSString *ccAnnounceColor;
extern NSString *ccNormalColor;

extern NSString *ccCheckboxDrawStyle;
extern NSString *ccLeadCircleStrokeWidth;
extern NSString *ccLeadCircleColorKey;

extern NSString *ccTypeMagicFractionsKey;
extern NSString *ccTypeMagicSuitSymbolsKey;
extern NSString *ccMagicSuitSymbolCodeKey;

extern const double SCALE_MULT;

@interface CommonStrings : NSObject

@end
