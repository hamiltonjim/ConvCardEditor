//
//  CCEUnitTransformer.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/23/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEUnitTransformer : NSValueTransformer

+ (void)registerTransformer;

@property NSInteger selectedUnit;

@end
