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

enum kMultiCheckShape {
    kCheckboxes = 0,
    kOvals = 1
    };

@interface CCEModelledControl : NSManagedObject

@property (readonly, nonatomic) NSString *controlType;
@property (readonly, nonatomic) NSNumber *isIndexed;
@property (readonly, nonatomic) NSNumber *numParts;

@end

@interface CCEModelledControl (Control)

@property (nonatomic) NSString *name;

@property (nonatomic) NSManagedObject *cardType;
@property (nonatomic) NSSet *values;

    // Every control type has a property called "location", except
    // MultiCheck; it has a set property ("locations"); but defines
    // setLocation: to _add_ a location object to the set.
@property (nonatomic) NSManagedObject *location;

    // make control view listen to changes in color
- (void)observeLocation:(NSManagedObject *)location
             forControl:(NSControl <CCDebuggableControl> *)control;
- (void)stopObservingLocation:(NSManagedObject *)location
                   forControl:(NSControl <CCDebuggableControl> *)control;

- (void)observeColor:(CCELocationController *)observer;
- (void)unobserveColor:(CCELocationController *)observer;

@end

