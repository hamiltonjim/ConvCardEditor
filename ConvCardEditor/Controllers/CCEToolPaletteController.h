//
//  CCEToolPaletteController.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/25/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCECardTypeEditorController;

@interface CCEToolPaletteController : NSObject

@property NSNumber *value;

@property IBOutlet NSButton *selectButton;
@property IBOutlet NSButton *textButton;
@property IBOutlet NSButton *singleCheckButton;
@property IBOutlet NSButton *multiCheckButton;
@property IBOutlet NSButton *leadChoiceButton;

@property (weak) IBOutlet CCECardTypeEditorController *controller;
@property IBOutlet NSPanel *toolsPalette;

- (IBAction)chooseControl:(id)sender;

- (void)chooseNextControl;

@end
