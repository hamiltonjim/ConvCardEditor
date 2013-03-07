//
//  CCEDuplicateNamer.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEDuplicateNamer.h"
#import "NSString+CCEStringRangeExtras.h"

static CCEDuplicateNamer *theInstance = nil;
static NSString *copyStr = nil;

enum ECopyFormat {
    kJustAddCopy,
    kJustAdd2,
    kEvalAndAddNum
};

@interface CCEDuplicateNamer ()

- (NSInteger)eval:(NSString *)string inRange:(NSRange)range;

@end

@implementation CCEDuplicateNamer

- (id)init
{
    @synchronized([self class]) {
        if (theInstance != nil)
            return theInstance;
        
        if (self = [super init]) {
            copyStr = NSLocalizedString(@"copy",
                                        @"word that indicates a simple copy of another object;");
        }
        
        theInstance = self;
        return self;
    }
}

- (void)dealloc
{
    theInstance = nil;
}

+ (CCEDuplicateNamer *)instance
{
    @synchronized(self) {
        if (theInstance == nil) {
            theInstance = [self new];
        }
    }
    
    return theInstance;
}

- (NSString *)nameForDuplicateOfName:(NSString *)oldName
{
    @try {
        
        NSRange range = [oldName rangeOfString:copyStr options:NSBackwardsSearch];
        NSRange nRange;
        NSInteger copyNum;
        NSInteger copyFmt;
        NSInteger length = oldName.length;
        NSInteger xlen = range.location + copyStr.length;
        if (range.location == NSNotFound) {    // simple
            copyFmt = kJustAddCopy;
        } else if (xlen == length) {
            copyFmt = kJustAdd2;
        } else {
            copyFmt = kEvalAndAddNum;
            nRange.location = xlen;
            nRange.length = length - xlen;
            
            NSRange numericRange = [oldName rangeOfSubstringFromSet:[NSCharacterSet decimalDigitCharacterSet]
                                                            options:0
                                                              range:nRange];
            NSRange whiteRange = [oldName rangeOfSubstringFromSet:[NSCharacterSet whitespaceCharacterSet]
                                                          options:0
                                                            range:nRange];
            if (numericRange.location == NSNotFound) {
                if (whiteRange.location == NSNotFound || NSEqualRanges(nRange, whiteRange)) {
                    copyFmt = kJustAdd2;
                } else {
                    copyFmt = kJustAddCopy;
                }
            } else if (whiteRange.location != NSNotFound &&
                       whiteRange.location + whiteRange.length < numericRange.location) {
                copyFmt = kJustAddCopy;
            } else if (numericRange.location + numericRange.length < length) {
                whiteRange = [oldName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]
                                                      options:0
                                                        range:NSMakeRange(numericRange.location, length - numericRange.location)];
                if (whiteRange.location == NSNotFound ||
                    (whiteRange.location == numericRange.location + numericRange.length &&
                    whiteRange.length == length - whiteRange.location)) {
                        // number is valid
                    copyNum = [self eval:oldName inRange:numericRange];
                    copyFmt = kEvalAndAddNum;
                } else {
                    copyFmt = kJustAddCopy;
                }
            } else {
                copyNum = [self eval:oldName inRange:numericRange];
                copyFmt = kEvalAndAddNum;
            }
        }
        
            // else, there's already a copy
            //
        
        NSString *returnStr = nil;
        switch (copyFmt) {
            case kJustAddCopy:
                returnStr = [oldName stringByAppendingFormat:NSLocalizedString(@" %@",
                                                                               @"format for adding \"copy\""),
                             copyStr];
                break;
                
            case kJustAdd2:
                copyNum = 2;
                    // fall thru
                
            case kEvalAndAddNum:
            {
                returnStr = [[oldName substringToIndex:range.location]
                             stringByAppendingFormat:NSLocalizedString(@"%@ %ld", @"format for adding \"copy n\""),
                             copyStr, copyNum];
            }
                break;
        }
        
        return returnStr;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception processing string %@: %@", oldName, exception);
    }
    @finally {
        
    }
}

- (NSInteger)eval:(NSString *)string inRange:(NSRange)range
{
    NSInteger value = [[string substringWithRange:range] integerValue];
    return value + 1;
}

@end
