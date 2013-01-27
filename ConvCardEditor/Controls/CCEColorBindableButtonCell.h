//
//  CCEColorBindableButtonCell.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCEColorBindableButtonCell : NSButtonCell

    // create properties as read-only; use ONLY the method below to write
@property (readonly) id observedObject;
@property (readonly) NSString *observedKeypath;

@property (readonly) NSColor *color;

- (void)observeTextColorFrom:(id)object keypath:(NSString *)keypath;

@end
