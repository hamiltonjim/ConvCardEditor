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

@property (weak) IBOutlet NSButton *selectButton;
@property (weak) IBOutlet NSButton *textButton;
@property (weak) IBOutlet NSButton *singleCheckButton;
@property (weak) IBOutlet CCEToolWithVariantButton *multiCheckButton;
@property (weak) IBOutlet CCEToolWithVariantButton *leadChoiceButton;

@property (weak) IBOutlet CCEControlsViewController *controller;
@property IBOutlet NSPanel *toolsPalette;

@property BOOL variant;

- (IBAction)chooseControl:(id)sender;
- (IBAction)variantChooseControl:(id)sender;

- (IBAction)chooseControlByTag:(id)sender;

- (void)selectControlTagValue:(NSInteger)value;

- (void)chooseNextControl;

- (void)hide;
- (void)show;

+ (NSInteger)count;

@end
