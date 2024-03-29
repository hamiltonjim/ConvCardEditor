//
//  CCETabConnector.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/12/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

/*
    Controls connection of "next responders" (that is the NSResponder
    field that is set) for Text models within a card definition.
 
    This class is NOT a singleton, but there should only ever be 
    one instance (per card editor).  The instance is created with
    the Controller nib (though its use only makes sense in edit mode).
 */

#import <Foundation/Foundation.h>
#import "CCDebuggableControl.h"

@class CCEControlsViewController;
@class CCETextModel;

@interface CCETabConnector : NSObject

@property IBOutlet NSPanel *connectorPanel;
@property (weak) IBOutlet CCEControlsViewController *controller;

@property NSNumber *inSetMode;

- (void)doOpen:(NSControl <CCDebuggableControl> *)curSelected;

- (IBAction)startConnection:(id)sender;
- (void)chooseTarget:(NSControl <CCDebuggableControl> *)target;
- (IBAction)finishConnection:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)unset:(id)sender;

- (BOOL)shouldOpenFor:(NSControl <CCDebuggableControl> *)object;

@end
