//
//  CCEIncrementBindableStepper.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/12/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCEIncrementBindableStepper : NSStepper

    // create properties as read-only; use ONLY the method below to write
@property (readonly) id observedObject;
@property (readonly) NSString *observedKeypath;

- (void)observeIncrementFrom:(id)object keypath:(NSString *)keypath;

@end
