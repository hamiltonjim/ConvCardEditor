//
//  CCECardStyleDocument.h
//  ConvCardEditor
//
//  Created by Jim Hamilton on 2/15/13.
//  Copyright (c) 2013 Jim Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FixedNSImageView;
@class AppDelegate;

extern NSString *cceStyledocType;

@interface CCECardStyleDocument : NSDocument

- (IBAction)importButton:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)doImport;

+ (void)exportCardStyle:(NSManagedObject *)card;

+ (void)importCardStyleTo:(AppDelegate *)delegate;

@end