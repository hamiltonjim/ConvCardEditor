//
//  CCEIncrementBindableStepper.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/12/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEIncrementBindableStepper.h"

@implementation CCEIncrementBindableStepper

@synthesize observedObject;
@synthesize observedKeypath;


- (void)observeIncrementFrom:(id)object keypath:(NSString *)keypath
{
    if (observedObject != nil && observedKeypath != nil) {
        [observedObject removeObserver:self forKeyPath:observedKeypath];
    }
    
    observedObject = object;
    observedKeypath = keypath;
    
    if (observedObject != nil && observedKeypath != nil) {
        [observedObject addObserver:self
                         forKeyPath:keypath
                            options:NSKeyValueObservingOptionInitial
                            context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == observedObject && [keyPath isEqualToString:observedKeypath]) {
        double val = [[object valueForKeyPath:keyPath] doubleValue];
        if (val > 0.0)
            [self setIncrement:val];
        return;
    }
    
    if ([[super class] instancesRespondToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
