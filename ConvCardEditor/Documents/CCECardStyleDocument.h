//
//  CCECardStyleDocument.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CCEDocument.h"

extern NSString *cceStyledocType;

@interface CCECardStyleDocument : CCEDocument

- (IBAction)importButton:(id)sender;
- (IBAction)cancel:(id)sender;

+ (void)exportCardStyle:(NSManagedObject *)card;

+ (void)importCardStyle;

- (void)doImport;

@end
