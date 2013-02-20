//
//  ConvCardEditorTests.m
//  ConvCardEditorTests
//
//  Created by Jim Hamilton on 12/28/12.
//  Copyright (c) 2012 Jim Hamilton. All rights reserved.
//

#import "ConvCardEditorTests.h"
#import "fuzzyMath.h"

@implementation ConvCardEditorTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testFuzzy
{
//    STFail(@"Unit tests are not implemented yet in ConvCardEditorTests");

    [self count1bitsIn:64 expect:1];
    [self count1bitsIn:127 expect:7];
    
    static int bitsArray[] = {32, 1, 2, 2, 3};
    for (NSUInteger val = 0xffffffff, bits = 0; val < 0x100000004; ++val, ++bits) {
        [self count1bitsIn:val expect:bitsArray[bits]];
    }
    
    double x = 1.0;
    double y = 1.0e-9;
    STAssertTrue(fuzzyZero(x - x + y), @"fuzzyZero 1.000000001 - 1");
    STAssertTrue(fuzzyCompare(x, x + y) == 0, @"fuzzyCompare");
}

- (void)count1bitsIn:(NSUInteger)value expect:(int)expected
{
    STAssertTrue(expected == count1bits(value), @"%d 1's in %ld", expected, value);
}

@end
