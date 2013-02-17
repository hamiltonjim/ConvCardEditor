//
//  CCEToolPaletteController.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/25/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCEControlsViewController;
@class CCEToolWithVariantButton;

@interface CCEToolPaletteController : NSResponder

@property NSNumber *value;

@property IBOutlet NSButton *selectButton;
@property IBOutlet NSButton *textButton;
@property IBOutlet NSButton *singleCheckButton;
@property IBOutlet CCEToolWithVariantButton *multiCheckButton;
@property IBOutlet CCEToolWithVariantButton *leadChoiceButton;

@property (weak) IBOutlet CCEControlsViewController *controller;
@property IBOutlet NSPanel *toolsPalette;

@property BOOL variant;

- (IBAction)chooseControl:(id)sender;
- (IBAction)variantChooseControl:(id)sender;

- (IBAction)chooseControlByTag:(id)sender;

- (void)chooseNextControl;

- (void)hide;
- (void)show;

@end
