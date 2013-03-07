//
//  CCEValueBindingTransformer.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/28/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *cceStringToIntegerTransformer;
extern NSString *cceStringToDoubleTransformer;
extern NSString *cceIntegerToStringTransformer;
extern NSString *cceDoubleToStringTransformer;

    // transforms NSString to NSNumber of type BOOL
@interface CCEValueBindingTransformer : NSValueTransformer

@end

    // transforms NSString to NSNumber of type NSInteger
@interface CCEStringToIntegerTransforemer : CCEValueBindingTransformer

@end

    // transforms NSString to NSNumber of type double
@interface CCEStringToDoubleTransformer : CCEValueBindingTransformer

@end

    // switches the sense
@interface CCEAbstractToStringTransformer : CCEValueBindingTransformer

@end

    // NSNumber (Integer) to string
@interface CCEIntegerToStringTransforemer : CCEAbstractToStringTransformer

@end

    // NSNumber (double) to string
@interface CCEDoubleToStringTransformar : CCEAbstractToStringTransformer

@end