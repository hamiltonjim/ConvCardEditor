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

#import "CCMatrix.h"

static BOOL CCDebuggableControl_enableDebugMode = NO;
static BOOL CCDebuggableControl_logClicks = NO;

@implementation CCDebuggableControlEnable

+ (void)setEnabled:(BOOL)enabled {
    CCDebuggableControl_enableDebugMode = enabled;
}

+ (void)toggleEnabled {
    CCDebuggableControl_enableDebugMode = !CCDebuggableControl_enableDebugMode;
}

+ (BOOL)enabled {
    return CCDebuggableControl_enableDebugMode;
}

+ (void)setLogClicks:(BOOL)log
{
    CCDebuggableControl_logClicks = log;
}

+ (void)toggleLogClicks
{
    CCDebuggableControl_logClicks = !CCDebuggableControl_logClicks;
}

+ (BOOL)logClicks
{
    return CCDebuggableControl_logClicks;
}

+ (void)logIfWanted:(NSEvent *)event inView:(NSView *)view
{
    if (!CCDebuggableControl_logClicks)
        return;
    
    NSString *eventName;
    switch (event.type) {
        case NSLeftMouseDown:
            eventName = @"LeftMouseDown";
            break;
            
        case NSLeftMouseUp:
            eventName = @"LeftMouseUp";
            break;
            
        case NSRightMouseDown:
            eventName = @"RightMouseDown";
            break;
            
        case NSRightMouseUp:
            eventName = @"RightMouseUp";
            break;
            
        default:
            return;
    }
    
    NSLog(@"%@ in view %@ at %@", eventName, view, NSStringFromPoint(event.locationInWindow));
}

+ (void)logIfWanted:(NSInteger)part inMatrix:(CCMatrix *)view
{
    if (!CCDebuggableControl_logClicks)
        return;
    
    NSLog(@"Click in matrix %@, index %ld", view, part);
}

@end
