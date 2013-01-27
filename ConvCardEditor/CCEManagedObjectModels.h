//
//  CCEManagedObjectModels.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/8/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@class CCEModelledControl;

@interface NSManagedObject (CardType)

@property (nonatomic) NSString *cardName;
@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *fileUrl;
@property (nonatomic) NSNumber *height;
@property (nonatomic) NSNumber *width;

@property (nonatomic) NSSet *cards;
@property (nonatomic) NSSet *settings;

@end

@interface NSManagedObject (ConventionCard)

@property (nonatomic) NSString *partnershipName;
@property (nonatomic) NSString *fontName;

@property (nonatomic) NSManagedObject *cardType;
@property (nonatomic) NSSet *values;

@end

@interface NSManagedObject (Setting)

@property (nonatomic) NSString *value;

@property (nonatomic) NSManagedObject *card;
@property (nonatomic) NSSet *controls;

@end

@interface NSManagedObject (Checkbox)

@property (nonatomic) NSNumber *dimX;
@property (nonatomic) NSNumber *dimY;

@end


    // MultiCheck is either checkboxes or circles
enum MultiCheckShape {
    checkboxes,
    ovals
};

