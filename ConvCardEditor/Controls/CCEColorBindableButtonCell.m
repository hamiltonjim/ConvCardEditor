//
//  CCEColorBindableButtonCell.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEColorBindableButtonCell.h"

@implementation CCEColorBindableButtonCell

@synthesize observedObject;
@synthesize observedKeypath;

@synthesize color;

- (void)observeTextColorFrom:(id)object keypath:(NSString *)keypath
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
        id newColor = [NSUnarchiver unarchiveObjectWithData:[observedObject valueForKeyPath:observedKeypath]];
        if ([newColor isKindOfClass:[NSColor class]]) {
            color = newColor;
            
            NSMutableAttributedString *title = [[self attributedTitle] mutableCopy];
            [title addAttribute:NSForegroundColorAttributeName
                          value:newColor
                          range:NSMakeRange(0, [title length])];
            [self setAttributedTitle:title];
        }
    }
}

@end
