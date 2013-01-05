//
//  CCECardType.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 1/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CCECardType : NSManagedObject {
    NSView *scaleCalculatedForView;
    double scale;
}

- (double)scale:(NSView *)view;

@end
