//
//  NSString+CCEStringRangeExtras.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/4/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "NSString+CCEStringRangeExtras.h"

@implementation NSString (CCEStringRangeExtras)

- (NSRange)rangeOfSubstringFromSet:(NSCharacterSet *)aSet
                           options:(NSStringCompareOptions)mask
                             range:(NSRange)searchRange
{
    NSRange range = [self rangeOfCharacterFromSet:aSet options:mask range:searchRange];
    if (range.location == NSNotFound)
        return range;
    
    NSUInteger stop = searchRange.location + searchRange.length;
    for (NSUInteger index = range.location; ++index < stop; ) {
        if ([aSet characterIsMember:[self characterAtIndex:index]]) {
            ++range.length;
        }
    }
    
    return range;
}


@end
