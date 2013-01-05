//
//  CCDebuggableControl.h
//  CCardX
//
//  Created by Jim Hamilton on 9/11/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCDebuggableControl.h,v 1.2 2010/12/21 05:13:26 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCDebuggableControlEnable.h"

    // Protocol to allow a globally enabled, debuggable control.  It's
    // up to the conforming control cell how to draw debug mode; the
    // main thing is, debug mode can be turned on individually, then
    // cut off globally.  The extern declared below is defined in
    // CCDebuggableControlEnable.m; set the value to NO to turn off
    // debug mode everywhere.

@protocol CCDebuggableControl

@required
- (void) setDebugMode:(BOOL)newDebugMode;

@optional
- (BOOL) debugMode;

@end
