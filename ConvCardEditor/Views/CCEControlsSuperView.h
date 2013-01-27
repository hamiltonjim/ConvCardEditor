//
//  CCEControlsSuperView.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/23/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CCEControlsViewController;
@class FixedNSImageView;

@interface CCEControlsSuperView : NSView

@property double zoom;
@property (weak) IBOutlet CCEControlsViewController *viewController;
@property (weak) IBOutlet FixedNSImageView *superImageView;

@property (nonatomic) BOOL gridState;

@end
