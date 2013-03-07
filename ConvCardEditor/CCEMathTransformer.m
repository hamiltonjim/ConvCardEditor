//
//  CCEMathTransformer.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEMathTransformer.h"

@interface CCEMathTransformer ()

    // transformed value is value op operand
    // use kAddition (or kIAddition) and negative op for subtraction
    // use kMultiplication and reciprocal op for division
    // (that won't work well for integers, so there's kIDivision too)

@property (strong) NSString *tName;
@property NSUInteger operation;
@property (strong) NSNumber *theOperand;

@end

@implementation CCEMathTransformer

@synthesize tName;
@synthesize operation;
@synthesize theOperand;

+ (void)registerTransformer { /* nothing */ }
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)initWithName:(NSString *)name
         operation:(NSUInteger)op
             value:(NSNumber *)operand
{
    if ((self = [super init])) {
        tName = name;
        operation = op;
        theOperand = operand;
        
        [NSValueTransformer setValueTransformer:self forName:tName];
    }
    
    return self;
}

- (id)transformedValue:(NSNumber *)value
{
    switch (operation) {
        case kAddition: {
            double val = value.doubleValue;
            val += theOperand.doubleValue;
            return [NSNumber numberWithDouble:val];
        }
            
        case kMultiplication: {
            double val = value.doubleValue;
            val *= theOperand.doubleValue;
            return [NSNumber numberWithDouble:val];
        }
            
        case kIAddition: {
            NSInteger val = value.integerValue;
            val += theOperand.integerValue;
            return [NSNumber numberWithInteger:val];
        }
            
        case kIMultiply: {
            NSInteger val = value.integerValue;
            val *= theOperand.integerValue;
            return [NSNumber numberWithInteger:val];
        }
            
        case kIDivide: {
            NSInteger val = value.integerValue;
            val /= theOperand.integerValue;
            return [NSNumber numberWithInteger:val];
        }
    }

        // default:
    return value;
}

@end

@implementation CCETimesTen

+ (void)registerTransformer
{
    (void)[self new];
}

- (id)init
{
    self = [super initWithName:@"CCETimesTen"
                     operation:kMultiplication
                         value:[NSNumber numberWithDouble:10.0]];
    return self;
}

@end

@implementation CCEOneTenth

+ (void)registerTransformer
{
    (void)[self new];
}

- (id)init
{
    self = [super initWithName:@"CCEOneTenth"
                     operation:kMultiplication
                         value:[NSNumber numberWithDouble:0.1]];
    return self;
}

@end
