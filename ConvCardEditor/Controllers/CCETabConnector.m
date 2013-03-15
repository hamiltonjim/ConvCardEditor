//
//  CCETabConnector.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/12/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCETabConnector.h"
#import "CCEControlsViewController.h"
#import "CCETextModel.h"
#import "CCESizableTextField.h"

static const NSTimeInterval kInterval = 0.2;
static const NSInteger kMaxIterations = 20;

enum ETimerSteps {
    kHighlightFirst = 0,
    kHighlightBoth,
    kHighlightLast,
    kHighlightNeither,
    
    kNumberOfSteps
};

@interface CCETabConnector ()

@property IBOutlet NSPanel *infoPanel;

@property (weak) CCESizableTextField *selected;
@property (weak) CCESizableTextField *candNext;

@property (weak) CCETextModel *currentlySelected;
@property (weak) CCEModelledControl *nextRespCandidate;

@property NSTimer *animator;
@property NSInteger iterations;

- (void)timerInvoke:(NSTimer *)timer;
- (void)didEndSheet:(NSWindow *)sheet
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo;

@end

@implementation CCETabConnector

@synthesize connectorPanel;
@synthesize controller;

@synthesize infoPanel;

@synthesize selected;
@synthesize candNext;

@synthesize currentlySelected;
@synthesize nextRespCandidate;

@synthesize animator;
@synthesize iterations;

- (void)doOpen:(CCESizableTextField *)curSelected
{
    selected = curSelected;
    if (selected == nil)
        return;
    
    self.currentlySelected = (CCETextModel *)selected.modelledControl;
    if (currentlySelected != nil) {
        self.nextRespCandidate = currentlySelected.tabToNext;
    }
    self.inSetMode = [NSNumber numberWithBool:YES];
    
    [NSApp beginSheet:connectorPanel
       modalForWindow:infoPanel
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:NULL];
    [controller.window orderFront:self];
}

- (void)didEndSheet:(NSWindow *)sheet
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo
{
    [connectorPanel orderOut:self];
}

- (IBAction)startConnection:(id)sender
{
}

- (void)chooseTarget:(CCESizableTextField *)target
{
    self.candNext = target;
    
    if (candNext == nil)
        return;
    self.nextRespCandidate = (CCETextModel *)candNext.modelledControl;
    
    iterations = 0;
    if (animator != nil) {
        [animator invalidate];
    }
    animator = [NSTimer scheduledTimerWithTimeInterval:kInterval
                                                target:self
                                              selector:@selector(timerInvoke:)
                                              userInfo:NULL
                                               repeats:YES];
    self.inSetMode = [NSNumber numberWithBool:NO];
}

- (IBAction)finishConnection:(id)sender
{
    currentlySelected.tabToNext = nextRespCandidate;
    [self cancel:sender];
}

- (void)unAnimate
{
    if (animator != nil) {
        [animator invalidate];
    }
    selected.debugMode &= ~kShowHighlight;
    candNext.debugMode &= ~kShowHighlight;
}

- (IBAction)cancel:(id)sender
{
    if (sender == selected) {
        return;
    }
    
    self.inSetMode = [NSNumber numberWithBool:NO];
    [self unAnimate];
    
    [NSApp endSheet:connectorPanel];
}


- (void)timerInvoke:(NSTimer *)timer
{
    NSInteger step = iterations++ % kNumberOfSteps;
    
    switch (step) {
        case kHighlightFirst:
            selected.debugMode |= kShowHighlight;
            break;
            
        case kHighlightLast:
            selected.debugMode &= ~kShowHighlight;
            break;
            
        case kHighlightBoth:
            candNext.debugMode |= kShowHighlight;
            break;
            
        case kHighlightNeither:
            candNext.debugMode &= ~kShowHighlight;
            break;
    }
    
    if (iterations >= kMaxIterations) {
        [animator invalidate];
        animator = nil;
    }
}

- (IBAction)unset:(id)sender
{
    [self unAnimate];
    
    candNext = nil;
    nextRespCandidate = nil;
}

@end
