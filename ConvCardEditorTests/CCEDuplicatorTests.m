//
//  CCEDuplicatorTests.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/4/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEDuplicatorTests.h"
#import "CCEDuplicateNamer.h"

@implementation CCEDuplicatorTests

- (void)testDuplication
{
    NSArray *testStrings = @[@"foo", @"foo copy", @"foo copy 2", @"foo copy 27",
                             @"foo copy and more", @"foo copy   ", @"foo copy 2 more"];
    NSArray *expected = @[@"foo copy", @"foo copy 2", @"foo copy 3", @"foo copy 28",
                          @"foo copy and more copy", @"foo copy 2", @"foo copy 2 more copy"];
    
    NSEnumerator *testEnum = testStrings.objectEnumerator;
    NSEnumerator *expEnum = expected.objectEnumerator;
    
    NSString *testStr, *expStr;
    
    while ((testStr = testEnum.nextObject)) {
        expStr = expEnum.nextObject;
        NSString *actual = [[CCEDuplicateNamer instance] nameForDuplicateOfName:testStr];
        STAssertEqualObjects(expStr, actual, @"%@ does not match %@ (from %@)", actual, expStr, testStr);
    }
}

@end
