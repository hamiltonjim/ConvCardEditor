//
//  CCEPrefsController.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCBoxView.h"

@interface CCEPrefsController : NSObject {
    IBOutlet CCBoxView *fillBox;
    IBOutlet CCBoxView *checkBox;
    IBOutlet CCBoxView *xBox;
    
    IBOutlet NSMatrix *incrementMatrix;
    
    IBOutlet NSWindow *window;
}

@property NSNumber *incrementIndex;

- (void)windowDidLoad;
- (IBAction)showWindow:(id)sender;

- (IBAction)setStep:(id)sender;
- (NSNumber *)stepForIncrementValue;
- (NSNumber *)stepIsOther;

@end
