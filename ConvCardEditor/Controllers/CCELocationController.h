//
//  CCELocationController.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/30/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDebuggableControl.h"

@class CCEModelledControl;
@class CCELocation;


@interface CCELocationController : NSObject

@property (weak, nonatomic) CCEModelledControl *modelledControl;
@property (weak, nonatomic) CCELocation *watchedLocation;
@property (weak, nonatomic) NSControl <CCDebuggableControl> *viewedControl;

- (id)initWithModel:(CCEModelledControl *)model
            control:(NSControl <CCDebuggableControl> *)ctrl;
- (id)initWithModel:(CCEModelledControl *)model
              index:(NSInteger)index
            control:(NSControl<CCDebuggableControl> *)ctrl;

- (void)monitorLocation;
- (void)stopMonitoringLocation;

+ (NSInteger)count;

@end
