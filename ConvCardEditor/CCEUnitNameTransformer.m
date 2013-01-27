//
//  CCEUnitTransformer.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/23/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEUnitNameTransformer.h"
#import "CommonStrings.h"

@implementation CCEUnitNameTransformer

+ (void)registerTransformer
{
    CCEUnitNameTransformer *xform = [CCEUnitNameTransformer new];
    [NSValueTransformer setValueTransformer:xform forName:@"CCEUnitNameTransformer"];
}

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value
{
    NSInteger val = [value integerValue];
    NSString *result = nil;
    
    switch (val) {
        case kPointsDimension:
            result = ccUnitPoints;
            break;
            
        case kInchesDimension:
            result = ccUnitInches;
            break;
            
        case kCentimetersDimension:
            result = ccUnitCentimeters;
            break;
            
        default:
            break;
    }
    
    return result;
}

@end
