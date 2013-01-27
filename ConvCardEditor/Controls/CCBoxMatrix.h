//
//  CCBoxMatrix.h
//  CCardX
//
//  Created by Jim Hamilton on 8/20/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCBoxMatrix.h,v 1.3 2010/11/01 03:25:21 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCMatrix.h"
#import "CCCheckbox.h"

@interface CCBoxMatrix : CCMatrix 

    // Pass an array of just one color to use the same color for all 
    // Pass rectangles of individual boxes
- (id) initWithRects:(NSArray *)rects colors:(NSArray *)colorVals name:(NSString *)matrixName;

@end
