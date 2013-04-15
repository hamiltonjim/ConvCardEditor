//
//  CCEPartnershipDocument.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 3/16/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCEDocument.h"

@interface CCEPartnershipDocument : CCEDocument

+ (void)exportPartnership:(NSManagedObject *)partnership;

+ (void)importPartnership;


@end
