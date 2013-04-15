//
//  CCScalableView.h
//  CCardX
//
//  Created by Jim Hamilton on 10/17/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCScalableView.h,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import <Cocoa/Cocoa.h>


@interface CCScalableView : NSView {
    @protected
    NSSize size;
    NSRect bounds;
    double scale;
}

@property double scale;

@end
