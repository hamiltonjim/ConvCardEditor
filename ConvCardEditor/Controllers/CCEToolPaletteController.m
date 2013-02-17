//
//  CCEToolPaletteController.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/25/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEToolPaletteController.h"
#import "CCEToolWithVariantButton.h"
#import "CCEControlsViewController.h"
#import "CCEGradientView.h"
#import "CommonStrings.h"


@interface CCEToolPaletteController ()

@property NSButton *selectedButton;
@property BOOL sticky;

- (void)selectControl:(NSView *)control;
- (void)stickifyControl:(NSView *)control;
- (void)variantStickifyControl:(NSView *)control;
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
@synthesize variant;

static NSColor *startBlue;
static NSColor *endBlue;
static NSColor *startGray;
static NSColor *endGray;
static NSColor *startRed;
static NSColor *endRed;

static NSDictionary *controlsByTag = nil;

+ (void)initialize
{
    if (self == [CCEToolPaletteController class]) {
        startBlue = [NSColor colorWithCalibratedRed:0.0 green:0.2 blue:0.9 alpha:0.8];
        endBlue = [NSColor colorWithCalibratedRed:0.0 green:0.4 blue:0.75 alpha:0.4];
        
        startGray = [NSColor colorWithCalibratedWhite:0.5 alpha:0.8];
        endGray = [NSColor colorWithCalibratedWhite:0.7 alpha:0.4];
        
        startRed = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.8];
        endRed = [NSColor colorWithCalibratedRed:0.75 green:0.1 blue:0.4 alpha:0.4];
    }
}

- (void)awakeFromNib
{
    [self selectControl:selectButton];
    self.selectedButton = selectButton;
    [controller chooseControlType:selectButton];
    
    [self unselectControl:textButton];
    [self unselectControl:singleCheckButton];
    [self unselectControl:multiCheckButton];
    [self unselectControl:leadChoiceButton];
    
    [toolsPalette setBecomesKeyOnlyIfNeeded:YES];
    [toolsPalette setFloatingPanel:YES];
    
    SEL altAction = @selector(variantChooseControl:);
    [multiCheckButton setAlternateAction:altAction];
    [leadChoiceButton setAlternateAction:altAction];
    
    controlsByTag = @{
                      [NSNumber numberWithInteger:[selectButton tag]] : selectButton,
                      [NSNumber numberWithInteger:[textButton tag]] : textButton,
                      [NSNumber numberWithInteger:[singleCheckButton tag]] : singleCheckButton,
                      [NSNumber numberWithInteger:[multiCheckButton tag]] : multiCheckButton,
                      [NSNumber numberWithInteger:[leadChoiceButton tag]] : leadChoiceButton
                      };
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

- (void)variantStickifyControl:(NSView *)control
{
    CCEGradientView *gview = (CCEGradientView *)[control superview];
    gview.startingColor = startRed;
    gview.endingColor = endRed;
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
    if (selectedButton == sender && !variant) {
        if (sender != selectButton) {
            [self stickifyControl:sender];
            sticky = YES;
        }
    } else {
        sticky = NO;
        [self unselectControl:selectedButton];
        [self selectControl:sender];
    }
    
    variant = NO;
    selectedButton = sender;
    self.value = [NSNumber numberWithInteger:[sender tag]];
    controller.controlVariant = NO;
    [controller chooseControlType:sender];
    
    [controller.window makeKeyAndOrderFront:sender];
}

- (IBAction)variantChooseControl:(id)sender
{
    if (selectedButton != sender) {
        [self unselectControl:selectedButton];
    }
    sticky = YES;
    variant = YES;
    
    [self variantStickifyControl:sender];
    self.value = [NSNumber numberWithInteger:([sender tag] + kControlVariant)];
    controller.controlVariant = YES;
    [controller chooseControlType:sender];
}

- (IBAction)chooseControlByTag:(id)sender
{
    NSInteger tag = [sender tag];
    NSInteger modulo = tag % kTagGap;
    
    NSNumber *tagNumber = [NSNumber numberWithInteger:tag - modulo];
    
    NSButton *button = [controlsByTag objectForKey:tagNumber];
    if (button == nil) {
        NSBeep();
        return;
    }
    
    if (modulo == kControlVariant) {
        [self variantChooseControl:button];
    } else {
        [self chooseControl:button];
    }
}

- (void)chooseNextControl
{
    if ([selectedButton isKindOfClass:[CCEToolWithVariantButton class]]) {
        [self variantChooseControl:selectedButton];
        return;
    }
    
    if (sticky)
        return;
    
    [self chooseControl:selectButton];
}

- (void)hide
{
    [toolsPalette orderOut:self];
}
- (void)show
{
    [toolsPalette orderFront:self];
}

@end
