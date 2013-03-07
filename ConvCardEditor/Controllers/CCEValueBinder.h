//
//  CCEValueBinder.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/26/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDebuggableControl.h"

@class CCEModelledControl;

@interface CCEValueBinder : NSObject

- (id)initWithPartnership:(NSManagedObject *)partnership
                  control:(NSControl <CCDebuggableControl> *)modelledControl;
- (id)initWithPartnership:(NSManagedObject *)partnership
                  control:(NSControl<CCDebuggableControl> *)modelledControl
                    model:(CCEModelledControl *)model;

+ (NSInteger)count;

@end
