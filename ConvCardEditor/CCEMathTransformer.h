//
//  CCEMathTransformer.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

enum EMathOperator {
    kNoOp = 0,
    kAddition,
    kMultiplication,
    
    kIAddition = 10,
    kIMultiply,
    kIDivide
    };

@interface CCEMathTransformer : NSValueTransformer

- (id)initWithName:(NSString *)name
         operation:(NSUInteger)op
             value:(NSNumber *)operand;

+ (void)registerTransformer;

@end

@interface CCETimesTen : CCEMathTransformer

@end

@interface CCEOneTenth : CCEMathTransformer

@end
