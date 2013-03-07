//
//  CCLeadChoice.m
//  CCardX
//
//  Created by Jim Hamilton on 8/28/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCLeadChoice.m,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import "CCLeadChoice.h"
#import "AppDelegate.h"
#import "CCELocationController.h"
#import "NSView+ScaleUtilities.h"

@implementation CCLeadChoice

@synthesize parent;
@synthesize modelledControl;
@synthesize locationController;

- (id)monitorModel:(CCEModelledControl *)model
{
    modelledControl = model;
    
        // monitoring
    locationController = [[CCELocationController alloc] initWithModel:model control:self];
    
    return locationController;
}

- (void)stopMonitoring
{
    if (locationController != nil &&
        [locationController respondsToSelector:@selector(stopMonitoringLocation)]) {
        [locationController stopMonitoringLocation];
    }
    locationController = nil;
}

- (int) debugMode {
    return [[self cell] debugMode];
}
- (void) setDebugMode:(int)val {
    [[self cell] setDebugMode:val];
}

+ (id) cellClass {
    return [CCLeadChoiceCell class];
}

- (id) initWithFrame:(NSRect)frameRect {
    NSRect actualFrame = [NSView defaultScaleRect:frameRect];
    if ((self = [super initWithFrame:actualFrame])) {
        [self setButtonType:NSOnOffButton];
    }
    return self;
}

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget {
    BOOL retv = [super sendAction:theAction to:theTarget];
    
    if (parent) 
        [parent notify:self];
    
    return retv;
}

    // don't take keyboard input
- (BOOL) acceptsFirstResponder {
    return NO;
}

    // reindexing; only possible when this is a child control
- (BOOL)isReindexing {
    if (parent == nil) {
        return NO;
    }
    
        // if no parent, I can't even HAVE an index...
    return [parent isReindexing];
}

- (NSInteger)reindexFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex error:(NSError *__autoreleasing *)error
{
    if (parent == nil)
        return 0;
    
    return [parent reindexFrom:fromIndex to:toIndex error:error];
}

@end
