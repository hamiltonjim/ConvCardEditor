//
//  CCEPrefsController.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEPrefsController.h"
#import "CCCheckbox.h"
#import "CCCheckboxCell.h"

@implementation CCEPrefsController


- (void)windowDidLoad
{
    CCCheckbox *cbox;
    cbox = [[CCCheckbox alloc] initWithFrame:[fillBox bounds] color:[NSColor blackColor]];
    CCCheckboxCell *cell = (CCCheckboxCell *)[cbox cell];
    [cell setForceMode:[NSNumber numberWithInteger:CCCheckboxStyleSolid]];
    [fillBox addSubview:cbox];
    [cbox setIntegerValue:1];
    [cbox setEnabled:NO];
    
    cbox = [[CCCheckbox alloc] initWithFrame:[checkBox bounds] color:[NSColor blackColor]];
    cell = (CCCheckboxCell *)[cbox cell];
    [cell setForceMode:[NSNumber numberWithInteger:CCCheckboxStyleCheck]];
    [checkBox addSubview:cbox];
    [cbox setIntegerValue:1];
    [cbox setEnabled:NO];
    
    cbox = [[CCCheckbox alloc] initWithFrame:[xBox bounds] color:[NSColor blackColor]];
    cell = (CCCheckboxCell *)[cbox cell];
    [cell setForceMode:[NSNumber numberWithInteger:CCCheckboxStyleCross]];
    [xBox addSubview:cbox];
    [cbox setIntegerValue:1];
    [cbox setEnabled:NO];
}

- (IBAction)showWindow:(id)sender
{
    [window makeKeyAndOrderFront:sender];
}

@end
