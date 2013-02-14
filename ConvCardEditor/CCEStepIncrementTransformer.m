//
//  CCEStepIncrementTransformer.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/12/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEStepIncrementTransformer.h"
#import "CommonStrings.h"
#import "fuzzyMath.h"

static const double kOne = 1.0;
static const double kOneHalf = 0.5;

@implementation CCEStepIncrementTransformer

+ (void)registerTransformer
{
    CCEStepIncrementTransformer *xform = [CCEStepIncrementTransformer new];
    [NSValueTransformer setValueTransformer:xform forName:cceStepTransformer];
}

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return YES; }


- (id)transformedValue:(id)value
{
    double val = [value doubleValue];
    double transformedVal;
    
    if (fuzzyCompare(val, kOne) == 0) {
        transformedVal = kStepRadioOne;
    } else if (fuzzyCompare(val, kOneHalf) == 0) {
        transformedVal = kStepRadioHalf;
    } else {
        transformedVal = kStepRadioOther;
    }
    
    return [NSNumber numberWithInteger:transformedVal];
}

- (id)reverseTransformedValue:(id)value
{
    NSInteger val = [value integerValue];
    double transformedVal;
    
    switch (val) {
        case kStepRadioOne:
            transformedVal = kOne;
            break;
            
        case kStepRadioHalf:
            transformedVal = kOneHalf;
            break;
            
        default:
            transformedVal = [[NSUserDefaults standardUserDefaults] doubleForKey:cceStepIncrement];
            break;
    }
    
    return [NSNumber numberWithDouble:transformedVal];
}


@end
