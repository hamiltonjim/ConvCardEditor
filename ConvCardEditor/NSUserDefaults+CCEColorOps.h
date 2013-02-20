//
//  NSUserDefaults+CCEColorOps.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (CCEColorOps)

- (NSColor *)colorForKey:(NSString *)keyName;

@end
