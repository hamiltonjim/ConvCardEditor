//
//  NSUserDefaults+CCEColorOps.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "NSUserDefaults+CCEColorOps.h"

@implementation NSUserDefaults (CCEColorOps)

- (NSColor *)colorForKey:(NSString *)keyName
{
    return [NSUnarchiver unarchiveObjectWithData:[self dataForKey:keyName]];
}

@end
