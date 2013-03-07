//
//  CCEValueBindingTransformer.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/28/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

NSString *cceStringToIntegerTransformer = @"CCEStringToIntegerTransformer";
NSString *cceStringToDoubleTransformer = @"CCEStringToDoubleTransformer";
NSString *cceIntegerToStringTransformer = @"CCEIntegerToStringTransformer";
NSString *cceDoubleToStringTransformer = @"CCEDoubleToStringTransformer";

#import "CCEValueBindingTransformer.h"

enum ENumberType {
    kDefault = 0,
    kInteger = 1,
    kDouble,
    kFloat,
    kBoolean
};

@interface CCEValueBindingTransformer ()

@property NSInteger tType;

- (NSNumber *)typedNumber:(NSString *)strValue;
- (NSInteger)type;

@end

@implementation CCEValueBindingTransformer

@synthesize tType;

- (NSInteger)type
{
    return kDefault;
}

- (id)init
{
    self = [super init];
    if (self) {
        tType = [self type];
    }
    
    return self;
}

+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return YES; }

+ (void)initialize
{
    if (self == [CCEValueBindingTransformer class]) {
        [NSValueTransformer setValueTransformer:[CCEStringToIntegerTransforemer new]
                                        forName:cceStringToIntegerTransformer];
        [NSValueTransformer setValueTransformer:[CCEStringToDoubleTransformer new]
                                        forName:cceStringToDoubleTransformer];
        [NSValueTransformer setValueTransformer:[CCEIntegerToStringTransforemer new]
                                        forName:cceIntegerToStringTransformer];
        [NSValueTransformer setValueTransformer:[CCEDoubleToStringTransformar new]
                                        forName:cceDoubleToStringTransformer];
    }
}

- (id)transformedValue:(id)value
{
//    if (![value isKindOfClass:[NSString class]]) {
//        return nil;
//    }
    return [self typedNumber:value];
}

- (id)reverseTransformedValue:(id)value
{
    if ([value isKindOfClass:[NSString class]])
        return value;
    if (![value isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    return [(NSNumber *)value stringValue];
}

- (NSNumber *)typedNumber:(NSString *)strValue
{
    NSNumber *value = nil;
    switch (tType) {
        case kInteger:
            value = [NSNumber numberWithInteger:strValue.integerValue];
            break;
            
        case kDouble:
            value = [NSNumber numberWithDouble:strValue.doubleValue];
            break;
            
        case kFloat:
            value = [NSNumber numberWithFloat:strValue.floatValue];
            break;
            
        case kBoolean:
            value = [NSNumber numberWithBool:strValue.boolValue];
            break;
            
        default:
            [NSException raise:@"subclassResponsibility"
                        format:@"%@ is an abstract class; typedNumber: must be overridden", [self class]];
    }
    
    return value;
}

@end

@implementation CCEStringToIntegerTransforemer

- (NSInteger)type
{
    return kDouble;
}

@end

@implementation CCEStringToDoubleTransformer

- (NSInteger)type
{
    return kInteger;
}

@end

@implementation CCEAbstractToStringTransformer

+ (Class)transformedValueClass { return [NSString class]; }

- (id)transformedValue:(id)value
{
    return [super reverseTransformedValue:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [super transformedValue:value];
}

@end

@implementation CCEDoubleToStringTransformar

- (NSInteger)type
{
    return kDouble;
}

@end

@implementation CCEIntegerToStringTransforemer

- (NSInteger)type
{
    return kInteger;
}

@end
