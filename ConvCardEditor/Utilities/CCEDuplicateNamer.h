//
//  CCEDuplicateNamer.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/3/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEDuplicateNamer : NSObject

+ (CCEDuplicateNamer *)instance;

- (NSString *)nameForDuplicateOfName:(NSString *)oldName;

@end
