//
//  CCEUnitTransformer.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/23/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEUnitTransformer.h"
#import "CommonStrings.h"

@implementation CCEUnitTransformer

@synthesize selectedUnit;

+ (void)registerTransformer
{
    CCEUnitTransformer *xform = [CCEUnitTransformer new];
    [NSValueTransformer setValueTransformer:xform forName:@"CCEUnitTransformer"];
}

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)init
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:ccDimensionUnit
                                                   options:NSKeyValueObservingOptionInitial
                                                   context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([ccDimensionUnit isEqualToString:keyPath]) {
        selectedUnit = [[object valueForKeyPath:keyPath] integerValue];
    }
}

- (id)transformedValue:(id)value
{
    double val = [value doubleValue];
    
    switch (selectedUnit) {
        case kInchesDimension:
            val /= kInchDivisor;
            break;
            
        case kCentimetersDimension:
            val /= kCentimeterDivisor;
            break;
            
        case kPointsDimension:
            return value;
            
        default:
            NSLog(@"invalid units constant %g", val);
            return nil;
    }
    
    return [NSNumber numberWithDouble:val];
}

- (id)reverseTransformedValue:(id)value
{
    double val = [value doubleValue];
    
    switch (selectedUnit) {
        case kInchesDimension:
            val *= kInchDivisor;
            break;
            
        case kCentimetersDimension:
            val *= kCentimeterDivisor;
            break;
            
        case kPointsDimension:
            return value;
            
        default:
            NSLog(@"invalid units constant %g", val);
            return nil;
    }
    
    return [NSNumber numberWithDouble:val];
}


@end
