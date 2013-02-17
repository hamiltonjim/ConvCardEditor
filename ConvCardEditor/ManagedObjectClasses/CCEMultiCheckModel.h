//
//  CCEMultiCheck.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/18/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEModelledControl.h"

@class CCELocation;

@interface CCEMultiCheckModel : CCEModelledControl

@property (nonatomic) NSNumber *shape;
@property (nonatomic) NSSet *locations;

- (CCELocation *)locationWithIndex:(NSInteger)index;

    // convenience method:
- (void)removeLocationWithIndex:(NSUInteger)index;

@end
