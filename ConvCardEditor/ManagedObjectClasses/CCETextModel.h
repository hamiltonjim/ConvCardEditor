//
//  CCETextModel.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/18/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEModelledControl.h"

@class CCELocation;

@interface CCETextModel : CCEModelledControl

@property (nonatomic) NSNumber *lines;
@property (nonatomic) CCELocation *location;
@property (nonatomic) NSNumber *fontSize;

@property (nonatomic) NSNumber *numeric;

@end
