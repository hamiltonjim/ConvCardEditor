//
//  CCEValueBindingTransformer.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/28/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

    // "value" bindings might require an NSNumber; all values in our datastore
    // are NSString.  These transformers handle both the transformation and
    // whether the value should be integer or floating (well, double).
extern NSString *cceStringToIntegerTransformer;
extern NSString *cceStringToDoubleTransformer;
extern NSString *cceIntegerToStringTransformer;
extern NSString *cceDoubleToStringTransformer;

    // Binding a string value to NSTextField (or descendant) is tricky when
    // the actual text is strictly numeric; this transformer ensures that
    // the fields "value" binding is always NSString, even if NSTextField
    // would prefer NSNumber.
extern NSString *cceStringToStringTransformer;

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

    // String to string, ashes to ashes... this transformer does nothing,
    // except prevent an NSTextField from putting an NSNumber in its
    // "value" binding.
@interface CCEStringToStringTransformer : CCEValueBindingTransformer

@end