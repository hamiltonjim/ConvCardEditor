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
    
        // fuzzyRound
    double threeOneFour = fuzzyRound(pi, -2, 0.5);
    STAssertTrue(fuzzyCompare(3.14, threeOneFour) == 0, @"pi to 2 decimals, 0.5");
    double threeOneFive = fuzzyRound(pi, -2, 0.1);
    STAssertTrue(fuzzyCompare(3.15, threeOneFive) == 0, @"pi to 2 decimals, 0.1");
    
    threeOneFour = fuzzyRound(-pi, -2, 0.5);
    STAssertTrue(fuzzyCompare(-3.14, threeOneFour) == 0, @"-pi to 2 decimals, 0.5");
    threeOneFive = fuzzyRound(-pi, -2, 0.1);
    STAssertTrue(fuzzyCompare(-3.15, threeOneFive) == 0, @"-pi to 2 decimals, 0.1");
    
    double thirty = fuzzyRound(33, 1, 0.5);
    STAssertTrue(fuzzyCompare(30, thirty) == 0, @"33 to nearest decade, 0.5");
    
    double point7 = fuzzyRound(1.7, 0, 0.75);
    STAssertTrue(fuzzyCompare(1.0, point7) == 0, @"1.7 down at 0.75");
    double point8 = fuzzyRound(1.8, 0, 0.75);
    STAssertTrue(fuzzyCompare(2.0, point8) == 0, @"1.8 up at 0.75");
}

- (void)count1bitsIn:(NSUInteger)value expect:(int)expected
{
    STAssertTrue(expected == count1bits(value), @"%d 1's in %ld", expected, value);
}

@end
