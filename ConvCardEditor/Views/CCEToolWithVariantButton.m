//
//  CCEToolWithVariantButton.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEToolWithVariantButton.h"

@implementation CCEToolWithVariantButton

@synthesize alternateAction;

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget
{
    NSInteger flags = [[self cell] mouseDownFlags];
    BOOL alt = flags & NSAlternateKeyMask;
    
    if (alt) {
        if (alternateAction != nil && theTarget != nil) {
            [self sendAlternateAction:self];
            return YES;
        }
    }
    
    return [super sendAction:theAction to:theTarget];
}

- (IBAction)sendAlternateAction:(id)sender
{
    if (alternateAction == nil)
        [super sendAction:[self action] to:[self target]];
    else
        [super sendAction:alternateAction to:[self target]];
}

@end
