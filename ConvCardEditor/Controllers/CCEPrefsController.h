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
    
    IBOutlet NSWindow *window;
}

- (void)windowDidLoad;
- (IBAction)showWindow:(id)sender;

@end
