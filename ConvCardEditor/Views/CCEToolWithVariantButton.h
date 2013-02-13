//
//  CCEToolWithVariantButton.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCEToolWithVariantButton : NSButton

@property SEL alternateAction;

- (IBAction)sendAlternateAction:(id)sender;

@end
