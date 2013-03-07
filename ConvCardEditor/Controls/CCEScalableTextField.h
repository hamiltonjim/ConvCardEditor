//
//  CCEScalableTextField.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/20/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCEScalableTextField <NSObject>

- (void)setFrame:(NSRect)frameRect forRescaling:(BOOL)rescaling;

@end
