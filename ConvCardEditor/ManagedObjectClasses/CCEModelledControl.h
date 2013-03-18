//
//  CCEModelledControl.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CCELocation.h"
#import "CCDebuggableControl.h"

@class CCELocationController;

extern NSString *entityCheckbox;
extern NSString *entityMultiCheck;
extern NSString *entityText;
extern NSString *entityLocation;

enum kMultiCheckShape {
    kCheckboxes = 0,
    kOvals = 1
    };

@interface CCEModelledControl : NSManagedObject

@property (nonatomic) NSString *name;

@property (readonly, nonatomic) NSString *controlType;
@property (readonly, nonatomic) NSNumber *isIndexed;
@property (readonly, nonatomic) NSNumber *numParts;

@property (readonly, nonatomic) NSNumber *mightBeNumeric;

@property (nonatomic) CCEModelledControl *tabToNext;
@property (nonatomic) CCEModelledControl *tabToPrevious;

- (BOOL)validateName:(id *)ioValue
               error:(NSError * __autoreleasing *)outError;

@end

@interface CCEModelledControl (Control)

@property (nonatomic) NSManagedObject *cardType;
@property (nonatomic) NSSet *values;

    // Every control type has a property called "location", except
    // MultiCheck; it has a set property ("locations"); but defines
    // setLocation: to _add_ a location object to the set.
@property (nonatomic) CCELocation *location;

@end

