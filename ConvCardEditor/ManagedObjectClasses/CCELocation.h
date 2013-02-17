//
//  CCELocation.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/17/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CCEModelledControl;

@interface CCELocation : NSManagedObject

@property (nonatomic) NSColor *color;

@property (nonatomic) NSNumber *colorCode;

@property (nonatomic) NSNumber *colorAlpha;
@property (nonatomic) NSNumber *colorRed; 
@property (nonatomic) NSNumber *colorGreen;
@property (nonatomic) NSNumber *colorBlue;

@property (nonatomic) NSNumber *locX;
@property (nonatomic) NSNumber *locY;
@property (nonatomic) NSNumber *height;
@property (nonatomic) NSNumber *width;
@property (nonatomic) NSNumber *index;  // for multiple-instance controls

@property (nonatomic) CCEModelledControl *checkControl;
@property (nonatomic) CCEModelledControl *multiCheckControl;
@property (nonatomic) CCEModelledControl *textControl;

    // location values
- (NSRect)rectValue;
- (void)setRectValue:(NSRect)rect;

- (NSPoint)originValue;
- (void)setOriginValue:(NSPoint)pt;

- (NSSize)sizeValue;
- (void)setSizeValue:(NSSize)sz;

@end