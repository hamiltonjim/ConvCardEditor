//
//  CCEControlTest.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/31/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDebuggableControl.h"

@class CCEModelledControl;

extern NSString *kTesterIsRunning;

@interface CCEControlTest : NSObject

@property (readonly) BOOL isRunning;
@property (readonly) NSControl <CCDebuggableControl> *control;

+ (void)stopAllTesters;
+ (NSUInteger)testerCount;

+ (CCEControlTest *)testerForModel:(CCEModelledControl *)model;
+ (CCEControlTest *)testerForControl:(NSControl <CCDebuggableControl> *)control;
+ (CCEControlTest *)testerForName:(NSString *)name;

/*
 Add a tester for the given control, optionally passing an object to be
 notified when the tester starts and stops running.  The notifyTarget MUST
 implement the KVO method -observeValueForKeyPath:ofObject:change:context:
 for the keypath kTesterIsRunning.  Pass nil for notifyTarget to ignore
 those state changes.
 */
+ (CCEControlTest *)newTesterForControl:(NSControl <CCDebuggableControl> *)control
                                 notify:(id)notifyTarget;

- (id)initWithControl:(NSControl <CCDebuggableControl> *)control
               notify:(id)notifyTarget;

- (void)cancel;

@end
