//
//  SelectionCounters.h
//
//  Created by Jim Hamilton on 6/13/2005.
//  Copyright 2005 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JfhSelectionTransformer : NSValueTransformer {

}

+ (void)registerTransformer;
- (NSUInteger)selectionCount:(NSArray *)array;

@end

@interface JfhNilSelectionTransformer : JfhSelectionTransformer {

}

@end

@interface JfhSingleSelectionTransformer : JfhSelectionTransformer {

}

@end

@interface JfhNotSingleSelectionTransformer : JfhSelectionTransformer {

}

@end

@interface JfhMultiSelectionTransformer : JfhSelectionTransformer {

}

@end
