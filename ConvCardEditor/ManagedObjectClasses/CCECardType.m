//
//  CCECardType.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCECardType.h"

@implementation CCECardType

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self setValue:@"new card" forKey:@"cardName"];
}

- (double)scale:(NSView *)view {
    if (view == nil) {
        [NSException raise:@"CCECardTypeNoView" format:@"CCECardType: no view"];
    }
    
    if (view != scaleCalculatedForView) {
        NSRect frame = [view frame];
        NSSize size = frame.size;
        
        double wscale = size.width / [[self valueForKey:@"width"] doubleValue];
        double hscale = size.height / [[self valueForKey:@"height"] doubleValue];
        
        double optimumScale = fmax(wscale, hscale);
        scale = optimumScale;
        scaleCalculatedForView = view;
    }
    
    return scale;
}

@end
