//
//  NSString+CCEStringRangeExtras.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/4/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CCEStringRangeExtras)

- (NSRange)rangeOfSubstringFromSet:(NSCharacterSet *)aSet
                           options:(NSStringCompareOptions)mask
                             range:(NSRange)searchRange;

@end
