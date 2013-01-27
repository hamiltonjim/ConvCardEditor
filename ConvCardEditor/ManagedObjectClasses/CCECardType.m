//
//  CCECardType.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCECardType.h"

@implementation CCECardType

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self setValue:@"new card" forKey:@"cardName"];
}

@end
