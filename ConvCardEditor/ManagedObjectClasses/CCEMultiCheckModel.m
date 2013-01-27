//
//  CCEMultiCheck.m
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/18/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import "CCEMultiCheckModel.h"
#import "CommonStrings.h"

@implementation CCEMultiCheckModel

@dynamic locations;
@dynamic shape;

- (void)setLocation:(NSManagedObject *)location
{
    NSMutableSet *locs = [self mutableSetValueForKey:@"locations"];
    if (locs != nil) {
        [locs addObject:location];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:ccModelLocation]) {
        return nil;
    }
    
    return [super valueForUndefinedKey:key];
}

- (id)location
{
    return nil;
}

@end
