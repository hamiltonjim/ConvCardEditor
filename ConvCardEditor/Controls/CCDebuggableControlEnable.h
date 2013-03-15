//
//  CCDebuggableControlEnable.h
//  CCardX
//
//  Created by Jim Hamilton on 9/12/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCDebuggableControlEnable.h,v 1.1 2010/12/21 05:13:27 jimh Exp $

@class CCMatrix;

@interface CCDebuggableControlEnable : NSObject

+ (void)setEnabled:(BOOL)enabled;
+ (void)toggleEnabled;
+ (BOOL)enabled;

+ (void)setLogClicks:(BOOL)log;
+ (void)toggleLogClicks;
+ (BOOL)logClicks;

+ (void)logIfWanted:(NSEvent *)event inView:(NSView *)view;
+ (void)logIfWanted:(NSInteger)part inMatrix:(CCMatrix *)view;

@end
