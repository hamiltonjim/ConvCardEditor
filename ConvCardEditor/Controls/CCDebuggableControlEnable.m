//
//  CCDebuggableControlEnable.m
//  CCardX
//
//  Created by Jim Hamilton on 9/12/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCDebuggableControlEnable.m,v 1.2 2010/12/21 05:13:27 jimh Exp $

#import "CCDebuggableControlEnable.h"
#import "CCDebuggableControl.h"
    // Please see comments in CCDebuggableControl.h

static BOOL CCDebuggableControl_enableDebugMode = NO;

@implementation CCDebuggableControlEnable

+ (void) setEnabled:(BOOL)enabled {
    CCDebuggableControl_enableDebugMode = enabled;
}

+ (void) toggleEnabled {
    CCDebuggableControl_enableDebugMode = !CCDebuggableControl_enableDebugMode;
}

+ (BOOL) enabled {
    return CCDebuggableControl_enableDebugMode;
}

@end
