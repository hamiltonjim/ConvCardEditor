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
    if ((self = [super initWithFrame:frameRect])) {
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

@end
