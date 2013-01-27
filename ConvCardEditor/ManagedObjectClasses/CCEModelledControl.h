//
//  CCEModelledControl.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CCELocation.h"

extern NSString *entityCheckbox;
extern NSString *entityMultiCheck;
extern NSString *entityText;

enum kMultiCheckShape {
    kCheckboxes = 0,
    kOvals = 1
    };

@interface CCEModelledControl : NSManagedObject

@property (readonly) NSString *controlType;
@property (readonly) NSNumber *isIndexed;
@property (readonly) NSNumber *numParts;

@property (weak) NSControl *controlInView;

@end

@interface CCEModelledControl (Control)

@property (nonatomic) NSString *name;

@property (nonatomic) NSManagedObject *cardType;
@property (nonatomic) NSSet *values;

    // Every control type has a property called "location", except
    // MultiCheck; it has a set property ("locations"); but defines
    // setLocation: to _add_ a location object to the set.
@property (nonatomic) NSManagedObject *location;

@end

