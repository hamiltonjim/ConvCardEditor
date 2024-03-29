//
//  CCctrlParent.h
//  CCardX
//
//  Created by Jim Hamilton on 8/20/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCctrlParent.h,v 1.2 2010/10/20 03:00:17 jimh Exp $

#import <Cocoa/Cocoa.h>


@protocol CCctrlParent

@property (nonatomic) NSMutableArray *controls;

- (void) notify:(NSControl *)sender;

- (NSControl *)childWith1Index:(NSUInteger)index;

- (BOOL)isReindexing;
- (NSInteger)reindexFrom:(NSUInteger)fromIndex
                      to:(NSUInteger)toIndex
                   error:(NSError *__autoreleasing *)error;

@end
