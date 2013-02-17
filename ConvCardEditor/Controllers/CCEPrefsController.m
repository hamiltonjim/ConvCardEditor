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
#import "CommonStrings.h"

static NSString *changedKey = @"stepIsOther";

@implementation CCEPrefsController

@synthesize incrementIndex;

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
    
        // increment value
    incrementIndex = [self stepForIncrementValue];
}

- (IBAction)showWindow:(id)sender
{
    [window makeKeyAndOrderFront:sender];
}

- (IBAction)setStep:(id)sender
{
    double value = -1.0;
    
    if (sender == incrementMatrix) {
        NSInteger matrixVal = [incrementMatrix selectedRow];
        [self willChangeValueForKey:changedKey];
        incrementIndex = [NSNumber numberWithInteger:matrixVal];
        [self didChangeValueForKey:changedKey];
        
        switch (matrixVal) {
            case kStepRadioOne:
                value = 1.0;
                break;
                
            case kStepRadioHalf:
                value = 0.5;
                break;
                
            default:
                    // do nothing
                break;
        }
    } else if ([sender respondsToSelector:@selector(doubleValue)]) {
        incrementIndex = [self stepForIncrementValue];
    }
    
    if (value > 0.0)
        [[NSUserDefaults standardUserDefaults] setDouble:value forKey:cceStepIncrement];
    
    
}

- (NSNumber *)stepForIncrementValue
{
    NSValueTransformer *xform = [NSValueTransformer valueTransformerForName:cceStepTransformer];
    return [xform transformedValue:[[NSUserDefaults standardUserDefaults]
                                    valueForKey:cceStepIncrement]];
}

- (NSNumber *)stepIsOther
{
    return [NSNumber numberWithBool:(incrementIndex.integerValue == kStepRadioOther)];
}

@end
