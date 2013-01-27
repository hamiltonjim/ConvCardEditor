//
//  CCLeadChoiceMatrix.h
//  CCardX
//
//  Created by Jim Hamilton on 8/28/10.
//  Copyright 2010 Jim Hamilton. All rights reserved.
//
//  $Id: CCLeadChoiceMatrix.h,v 1.1 2010/10/20 03:00:17 jimh Exp $

#import <Cocoa/Cocoa.h>
#import "CCMatrix.h"

@interface CCLeadChoiceMatrix : CCMatrix

    // Pass rectangles containing individual ovals
- (id) initWithRects:(NSArray *)rects name:(NSString *)matrixName;

@end
