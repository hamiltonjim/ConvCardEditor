//
//  CCEToolPaletteController.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/25/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEToolPaletteController.h"
#import "CCECardTypeEditorController.h"
#import "CCEGradientView.h"

@interface CCEToolPaletteController ()

@property IBOutlet NSButton *selectedButton;
@property BOOL sticky;

- (void)selectControl:(NSView *)control;
- (void)stickifyControl:(NSView *)control;
- (void)unselectControl:(NSView *)control;

@end

@implementation CCEToolPaletteController

@synthesize selectButton;
@synthesize textButton;
@synthesize singleCheckButton;
@synthesize multiCheckButton;
@synthesize leadChoiceButton;

@synthesize controller;

@synthesize value;

@synthesize toolsPalette;

@synthesize selectedButton;
@synthesize sticky;

static NSColor *startBlue;
static NSColor *endBlue;
static NSColor *startGray;
static NSColor *endGray;


+ (void)initialize
{
    if (self == [CCEToolPaletteController class]) {
        startBlue = [NSColor colorWithCalibratedRed:0.0 green:0.2 blue:0.9 alpha:0.8];
        endBlue = [NSColor colorWithCalibratedRed:0.0 green:0.4 blue:0.75 alpha:0.4];
        
        startGray = [NSColor colorWithCalibratedWhite:0.5 alpha:0.8];
        endGray = [NSColor colorWithCalibratedWhite:0.7 alpha:0.4];
    }
}

- (void)awakeFromNib
{
    [self selectControl:selectButton];
    self.selectedButton = selectButton;
    [controller setControlType:selectButton];
    
    [self unselectControl:textButton];
    [self unselectControl:singleCheckButton];
    [self unselectControl:multiCheckButton];
    [self unselectControl:leadChoiceButton];
    
    [toolsPalette setBecomesKeyOnlyIfNeeded:YES];
    [toolsPalette setFloatingPanel:YES];
}

- (void)selectControl:(NSView *)control
{
    CCEGradientView *gview = (CCEGradientView *)[control superview];
    gview.startingColor = startGray;
    gview.endingColor = endGray;
    [gview setNeedsDisplay:YES];
}

- (void)stickifyControl:(NSView *)control
{
    CCEGradientView *gview = (CCEGradientView *)[control superview];
    gview.startingColor = startBlue;
    gview.endingColor = endBlue;
    [gview setNeedsDisplay:YES];
}

- (void)unselectControl:(NSView *)control
{
    if (control == nil)
        return;
    
    CCEGradientView *gview = (CCEGradientView *)[control superview];
    gview.startingColor = [NSColor clearColor];
    gview.endingColor = nil;
    [gview setNeedsDisplay:YES];
}

- (IBAction)chooseControl:(id)sender
{
    if (selectedButton == sender) {
        if (sender != selectButton) {
            [self stickifyControl:sender];
            sticky = YES;
        }
    } else {
        sticky = NO;
        [self unselectControl:selectedButton];
        [self selectControl:sender];
    }
    
    selectedButton = sender;
    self.value = [NSNumber numberWithInteger:[sender tag]];
    [controller setControlType:sender];
    
    [controller.window makeKeyAndOrderFront:sender];
}

- (void)chooseNextControl
{
    if (sticky)
        return;
    
    [self chooseControl:selectButton];
}

@end
